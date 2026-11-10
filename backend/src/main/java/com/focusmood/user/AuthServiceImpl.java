package com.focusmood.user;

import com.focusmood.common.exception.AuthenticationFailedException;
import com.focusmood.common.exception.ConflictException;
import com.focusmood.common.exception.TooManyRequestsException;
import com.focusmood.security.ClientInfo;
import com.focusmood.security.LoginRateLimiter;
import com.focusmood.security.SessionService;
import com.focusmood.security.TokenIssuer;
import com.focusmood.user.dto.AuthResponse;
import com.focusmood.user.dto.LoginRequest;
import com.focusmood.user.dto.RefreshRequest;
import com.focusmood.user.dto.RegisterRequest;
import java.time.Clock;
import java.util.Locale;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
class AuthServiceImpl implements AuthService {

    private static final String INVALID_CREDENTIALS = "Correo o contraseña incorrectos.";

    private final UserRepository users;
    private final ProfileRepository profiles;
    private final PasswordEncoder passwordEncoder;
    private final TokenIssuer tokenIssuer;
    private final SessionService sessions;
    private final LoginRateLimiter rateLimiter;
    private final Clock clock;
    /** Hash de relleno para igualar el tiempo de respuesta cuando el correo no existe. */
    private final String dummyHash;

    AuthServiceImpl(UserRepository users, ProfileRepository profiles, PasswordEncoder passwordEncoder,
                    TokenIssuer tokenIssuer, SessionService sessions, LoginRateLimiter rateLimiter, Clock clock) {
        this.users = users;
        this.profiles = profiles;
        this.passwordEncoder = passwordEncoder;
        this.tokenIssuer = tokenIssuer;
        this.sessions = sessions;
        this.rateLimiter = rateLimiter;
        this.clock = clock;
        this.dummyHash = passwordEncoder.encode("no-existe-" + System.nanoTime());
    }

    @Override
    @Transactional
    public AuthResponse register(RegisterRequest request, ClientInfo client) {
        String email = normalize(request.email());
        if (users.existsByEmail(email)) {
            throw new ConflictException("Ya existe una cuenta registrada con ese correo.");
        }
        User user = users.save(new User(request.name().trim(), email,
                passwordEncoder.encode(request.password()), clock.instant()));
        profiles.save(new Profile(user.getId()));
        return startSession(user, client);
    }

    /**
     * Sin @Transactional a propósito: los fallos deben contarse en el limitador aunque se lance la excepción,
     * y no se retiene una conexión durante el cálculo de BCrypt.
     */
    @Override
    public AuthResponse login(LoginRequest request, ClientInfo client) {
        String email = normalize(request.email());
        String key = email + "|" + client.ip();
        if (rateLimiter.isBlocked(key)) {
            throw new TooManyRequestsException("Demasiados intentos fallidos. Inténtalo de nuevo en unos minutos.");
        }
        User user = users.findByEmail(email).orElse(null);
        String hash = user != null ? user.getPasswordHash() : dummyHash;
        boolean matches = passwordEncoder.matches(request.password(), hash);
        if (user == null || !matches || !user.isActive()) {
            rateLimiter.recordFailure(key);
            throw new AuthenticationFailedException(INVALID_CREDENTIALS);
        }
        rateLimiter.reset(key);
        return startSession(user, client);
    }

    @Override
    @Transactional(noRollbackFor = AuthenticationFailedException.class)
    public AuthResponse refresh(RefreshRequest request) {
        SessionService.Rotated rotated = sessions.rotate(request.refreshToken());
        User user = users.findById(rotated.userId()).filter(User::isActive).orElse(null);
        if (user == null) {
            sessions.revokeAll(rotated.userId());
            throw new AuthenticationFailedException("La sesión no es válida o ya expiró. Inicia sesión de nuevo.");
        }
        return toResponse(user, rotated.sessionId(), rotated.refreshToken());
    }

    private AuthResponse startSession(User user, ClientInfo client) {
        SessionService.Opened opened = sessions.open(user.getId(), client);
        return toResponse(user, opened.sessionId(), opened.refreshToken());
    }

    private AuthResponse toResponse(User user, String sessionId, String refreshToken) {
        TokenIssuer.IssuedToken token = tokenIssuer.issue(user.getId(), user.getEmail(), sessionId);
        return new AuthResponse(token.value(), "Bearer", token.expiresAt(), refreshToken,
                new AuthResponse.UserSummary(user.getId(), user.getName(), user.getEmail()));
    }

    static String normalize(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }
}
