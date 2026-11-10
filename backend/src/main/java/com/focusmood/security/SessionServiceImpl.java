package com.focusmood.security;

import com.focusmood.common.exception.AuthenticationFailedException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.HexFormat;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
class SessionServiceImpl implements SessionService {

    private static final String INVALID = "La sesión no es válida o ya expiró. Inicia sesión de nuevo.";
    /** Tope absoluto: aunque se renueve sin parar, la sesión muere a los 30 días. */
    private static final Duration ABSOLUTE_MAX = Duration.ofDays(30);

    private final UserSessionRepository sessions;
    private final SecurityProperties properties;
    private final Clock clock;
    private final SecureRandom random = new SecureRandom();

    SessionServiceImpl(UserSessionRepository sessions, SecurityProperties properties, Clock clock) {
        this.sessions = sessions;
        this.properties = properties;
        this.clock = clock;
    }

    @Override
    @Transactional
    public Opened open(Long userId, ClientInfo client) {
        Instant now = clock.instant();
        String id = UUID.randomUUID().toString();
        String secret = newSecret();
        sessions.save(new UserSession(id, userId, sha256(secret), now, now.plus(properties.refreshTtl()),
                client.userAgent(), client.ip()));
        return new Opened(id, id + "." + secret);
    }

    /** noRollbackFor: la revocación por reutilización debe persistirse aunque se lance la excepción. */
    @Override
    @Transactional(noRollbackFor = AuthenticationFailedException.class)
    public Rotated rotate(String refreshToken) {
        int dot = refreshToken.indexOf('.');
        if (dot <= 0 || dot == refreshToken.length() - 1) {
            throw new AuthenticationFailedException(INVALID);
        }
        String sessionId = refreshToken.substring(0, dot);
        String hash = sha256(refreshToken.substring(dot + 1));
        Instant now = clock.instant();

        UserSession session = sessions.findForUpdate(sessionId)
                .orElseThrow(() -> new AuthenticationFailedException(INVALID));
        if (!session.isActive(now)) {
            throw new AuthenticationFailedException(INVALID);
        }
        if (constantTimeEquals(hash, session.getPreviousRefreshHash())) {
            session.revoke();
            throw new AuthenticationFailedException(INVALID);
        }
        if (!constantTimeEquals(hash, session.getRefreshHash())) {
            throw new AuthenticationFailedException(INVALID);
        }
        String secret = newSecret();
        Instant cap = session.getCreatedAt().plus(ABSOLUTE_MAX);
        Instant expiry = now.plus(properties.refreshTtl());
        session.rotate(sha256(secret), now, expiry.isAfter(cap) ? cap : expiry);
        return new Rotated(session.getUserId(), session.getId(), session.getId() + "." + secret);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isActive(String sessionId) {
        return sessionId != null && sessions.isActive(sessionId, clock.instant());
    }

    @Override
    @Transactional
    public void revoke(Long userId, String sessionId) {
        sessions.findByIdAndUserId(sessionId, userId).ifPresent(UserSession::revoke);
    }

    @Override
    @Transactional
    public void revokeAll(Long userId) {
        sessions.revokeAll(userId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<SessionInfo> list(Long userId) {
        return sessions.findByUserIdAndRevokedFalseAndExpiresAtAfterOrderByLastUsedAtDesc(userId, clock.instant())
                .stream()
                .map(s -> new SessionInfo(s.getId(), s.getDevice(), s.getIp(), s.getCreatedAt(),
                        s.getLastUsedAt(), s.getExpiresAt()))
                .toList();
    }

    @Override
    @Transactional
    public int purgeExpired() {
        return sessions.purge(clock.instant().minus(Duration.ofDays(7)));
    }

    private String newSecret() {
        byte[] raw = new byte[32];
        random.nextBytes(raw);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(raw);
    }

    private static boolean constantTimeEquals(String a, String b) {
        return b != null && MessageDigest.isEqual(a.getBytes(StandardCharsets.UTF_8), b.getBytes(StandardCharsets.UTF_8));
    }

    private static String sha256(String value) {
        try {
            return HexFormat.of().formatHex(
                    MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }
}
