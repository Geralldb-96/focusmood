package com.focusmood.security;

import java.time.Clock;
import java.time.Instant;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.stereotype.Component;

@Component
class JwtTokenIssuer implements TokenIssuer {

    private final JwtEncoder encoder;
    private final SecurityProperties properties;
    private final Clock clock;

    JwtTokenIssuer(JwtEncoder encoder, SecurityProperties properties, Clock clock) {
        this.encoder = encoder;
        this.properties = properties;
        this.clock = clock;
    }

    @Override
    public IssuedToken issue(Long userId, String email, String sessionId) {
        Instant now = clock.instant();
        Instant expiresAt = now.plus(properties.jwtTtl());
        JwtClaimsSet claims = JwtClaimsSet.builder()
                .issuer("focusmood")
                .subject(String.valueOf(userId))
                .id(java.util.UUID.randomUUID().toString())
                .claim("sid", sessionId)
                .claim("email", email)
                .issuedAt(now)
                .expiresAt(expiresAt)
                .build();
        String value = encoder.encode(JwtEncoderParameters.from(JwsHeader.with(MacAlgorithm.HS256).build(), claims))
                .getTokenValue();
        return new IssuedToken(value, expiresAt);
    }
}
