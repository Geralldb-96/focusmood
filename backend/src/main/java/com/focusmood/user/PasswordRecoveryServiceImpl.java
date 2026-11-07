package com.focusmood.user;

import com.focusmood.common.exception.BusinessRuleException;
import com.focusmood.security.SecurityProperties;
import com.focusmood.user.dto.ForgotPasswordRequest;
import com.focusmood.user.dto.ResetPasswordRequest;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Clock;
import java.util.Base64;
import java.util.HexFormat;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
class PasswordRecoveryServiceImpl implements PasswordRecoveryService {

    private final UserRepository users;
    private final PasswordResetTokenRepository tokens;
    private final PasswordEncoder passwordEncoder;
    private final PasswordResetNotifier notifier;
    private final SecurityProperties properties;
    private final Clock clock;
    private final com.focusmood.security.SessionService sessions;
    private final SecureRandom random = new SecureRandom();

    PasswordRecoveryServiceImpl(UserRepository users, PasswordResetTokenRepository tokens,
                                PasswordEncoder passwordEncoder, PasswordResetNotifier notifier,
                                SecurityProperties properties, Clock clock,
                                com.focusmood.security.SessionService sessions) {
        this.sessions = sessions;
        this.users = users;
        this.tokens = tokens;
        this.passwordEncoder = passwordEncoder;
        this.notifier = notifier;
        this.properties = properties;
        this.clock = clock;
    }

    @Override
    @Transactional
    public void requestReset(ForgotPasswordRequest request) {
        // Respuesta idéntica exista o no la cuenta: evita enumerar correos registrados.
        User user = users.findByEmail(AuthServiceImpl.normalize(request.email())).orElse(null);
        if (user == null) {
            return;
        }
        byte[] raw = new byte[32];
        random.nextBytes(raw);
        String plainToken = Base64.getUrlEncoder().withoutPadding().encodeToString(raw);
        tokens.save(new PasswordResetToken(user.getId(), sha256(plainToken),
                clock.instant().plus(properties.resetTokenTtl())));
        notifier.send(user.getEmail(), plainToken);
    }

    @Override
    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        PasswordResetToken token = tokens.findByTokenHash(sha256(request.token()))
                .filter(t -> t.isUsable(clock.instant()))
                .orElseThrow(() -> new BusinessRuleException("El enlace de recuperación no es válido o ya expiró."));
        User user = users.findById(token.getUserId())
                .orElseThrow(() -> new BusinessRuleException("El enlace de recuperación no es válido o ya expiró."));
        user.changePasswordHash(passwordEncoder.encode(request.newPassword()));
        token.markUsed();
        // Cambiar la contraseña cierra todas las sesiones: si la cuenta estaba comprometida, el atacante sale.
        sessions.revokeAll(user.getId());
    }

    private static String sha256(String value) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }
}
