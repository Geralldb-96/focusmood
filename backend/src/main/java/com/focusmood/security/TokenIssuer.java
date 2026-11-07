package com.focusmood.security;

import java.time.Instant;

/** Abstracción para emitir tokens de acceso; permite cambiar JWT por otro mecanismo sin tocar el login. */
public interface TokenIssuer {

    IssuedToken issue(Long userId, String email, String sessionId);

    record IssuedToken(String value, Instant expiresAt) {
    }
}
