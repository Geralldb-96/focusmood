package com.focusmood.user;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/**
 * Implementación por defecto: no envía correo, solo registra el hecho. El token únicamente se escribe
 * en nivel DEBUG (perfil dev). Para producción, añade un adaptador SMTP anotado con @Primary.
 */
@Component
class LoggingPasswordResetNotifier implements PasswordResetNotifier {

    private static final Logger log = LoggerFactory.getLogger(LoggingPasswordResetNotifier.class);

    @Override
    public void send(String email, String plainToken) {
        log.info("Solicitud de recuperación de contraseña generada (sin proveedor de correo configurado).");
        log.debug("Token de recuperación para {}: {}", email, plainToken);
    }
}
