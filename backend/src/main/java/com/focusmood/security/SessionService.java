package com.focusmood.security;

import java.time.Instant;
import java.util.List;

/** Gestión de sesiones en servidor con refresh tokens opacos y rotativos. */
public interface SessionService {

    /** Abre una sesión nueva. El refresh token en claro solo se devuelve aquí. */
    Opened open(Long userId, ClientInfo client);

    /**
     * Canjea un refresh token por uno nuevo. Si el token ya fue rotado (reutilización), revoca la sesión
     * completa, porque indica que fue robado.
     */
    Rotated rotate(String refreshToken);

    boolean isActive(String sessionId);

    void revoke(Long userId, String sessionId);

    void revokeAll(Long userId);

    List<SessionInfo> list(Long userId);

    int purgeExpired();

    record Opened(String sessionId, String refreshToken) {
    }

    record Rotated(Long userId, String sessionId, String refreshToken) {
    }

    record SessionInfo(String id, String device, String ip, Instant createdAt, Instant lastUsedAt, Instant expiresAt) {
    }
}
