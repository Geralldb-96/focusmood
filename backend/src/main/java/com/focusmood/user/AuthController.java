package com.focusmood.user;

import com.focusmood.common.exception.TooManyRequestsException;
import com.focusmood.security.ClientInfo;
import com.focusmood.security.LoginRateLimiter;
import com.focusmood.security.SessionService;
import com.focusmood.user.dto.AuthResponse;
import com.focusmood.user.dto.ForgotPasswordRequest;
import com.focusmood.user.dto.LoginRequest;
import com.focusmood.user.dto.RefreshRequest;
import com.focusmood.user.dto.RegisterRequest;
import com.focusmood.user.dto.ResetPasswordRequest;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
class AuthController {

    private final AuthService authService;
    private final PasswordRecoveryService recoveryService;
    private final SessionService sessions;
    private final LoginRateLimiter rateLimiter;

    AuthController(AuthService authService, PasswordRecoveryService recoveryService, SessionService sessions,
                   LoginRateLimiter rateLimiter) {
        this.authService = authService;
        this.recoveryService = recoveryService;
        this.sessions = sessions;
        this.rateLimiter = rateLimiter;
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    AuthResponse register(@Valid @RequestBody RegisterRequest request, HttpServletRequest http) {
        return authService.register(request, ClientInfo.from(http));
    }

    @PostMapping("/login")
    AuthResponse login(@Valid @RequestBody LoginRequest request, HttpServletRequest http) {
        return authService.login(request, ClientInfo.from(http));
    }

    /** Renueva la sesión: el refresh token se rota y el anterior deja de servir. */
    @PostMapping("/refresh")
    AuthResponse refresh(@Valid @RequestBody RefreshRequest request) {
        return authService.refresh(request);
    }

    /** FCM-17: revoca en servidor la sesión del token presentado; el access token deja de valer al instante. */
    @PostMapping("/logout")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void logout(@AuthenticationPrincipal Jwt jwt) {
        sessions.revoke(Long.valueOf(jwt.getSubject()), jwt.getClaimAsString("sid"));
    }

    @PostMapping("/logout-all")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void logoutAll(@AuthenticationPrincipal Jwt jwt) {
        sessions.revokeAll(Long.valueOf(jwt.getSubject()));
    }

    @GetMapping("/sessions")
    List<SessionView> sessions(@AuthenticationPrincipal Jwt jwt) {
        String current = jwt.getClaimAsString("sid");
        return sessions.list(Long.valueOf(jwt.getSubject())).stream()
                .map(s -> new SessionView(s, s.id().equals(current)))
                .toList();
    }

    @DeleteMapping("/sessions/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void revokeSession(@AuthenticationPrincipal Jwt jwt, @PathVariable String id) {
        sessions.revoke(Long.valueOf(jwt.getSubject()), id);
    }

    @PostMapping("/forgot-password")
    @ResponseStatus(HttpStatus.ACCEPTED)
    void forgotPassword(@Valid @RequestBody ForgotPasswordRequest request, HttpServletRequest http) {
        String key = "forgot|" + http.getRemoteAddr();
        if (rateLimiter.isBlocked(key)) {
            throw new TooManyRequestsException("Demasiadas solicitudes. Inténtalo de nuevo en unos minutos.");
        }
        rateLimiter.recordFailure(key);
        recoveryService.requestReset(request);
    }

    @PostMapping("/reset-password")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        recoveryService.resetPassword(request);
    }

    record SessionView(String id, String device, String ip, java.time.Instant createdAt,
                       java.time.Instant lastUsedAt, java.time.Instant expiresAt, boolean current) {
        SessionView(SessionService.SessionInfo s, boolean current) {
            this(s.id(), s.device(), s.ip(), s.createdAt(), s.lastUsedAt(), s.expiresAt(), current);
        }
    }
}
