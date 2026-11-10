package com.focusmood.user.dto;

import java.time.Instant;

public record AuthResponse(String token, String tokenType, Instant expiresAt, String refreshToken, UserSummary user) {

    public record UserSummary(Long id, String name, String email) {
    }
}
