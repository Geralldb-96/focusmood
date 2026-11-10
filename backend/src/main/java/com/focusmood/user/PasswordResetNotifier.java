package com.focusmood.user;

/**
 * Puerto de salida para entregar el token de recuperación al usuario (correo, SMS...).
 * Permite sustituir la entrega sin modificar {@link PasswordRecoveryService}.
 */
public interface PasswordResetNotifier {

    void send(String email, String plainToken);
}
