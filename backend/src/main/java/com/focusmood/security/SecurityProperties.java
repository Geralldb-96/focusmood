package com.focusmood.security;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.Duration;
import java.util.List;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

/** Configuración de seguridad. El secreto JWT proviene únicamente de variables de entorno (RNF-08). */
@Validated
@ConfigurationProperties(prefix = "focusmood.security")
public record SecurityProperties(
        @NotBlank @Size(min = 32, message = "JWT_SECRET debe tener al menos 32 caracteres") String jwtSecret,
        Duration jwtTtl,
        Duration refreshTtl,
        Duration resetTokenTtl,
        List<String> allowedOrigins) {

    public SecurityProperties {
        jwtTtl = jwtTtl == null ? Duration.ofMinutes(15) : jwtTtl;
        refreshTtl = refreshTtl == null ? Duration.ofDays(7) : refreshTtl;
        resetTokenTtl = resetTokenTtl == null ? Duration.ofMinutes(30) : resetTokenTtl;
        allowedOrigins = allowedOrigins == null ? List.of() : allowedOrigins;
    }
}
