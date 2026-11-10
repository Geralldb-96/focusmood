package com.focusmood.user.dto;

/** Política única de contraseña (RF-02, sección 5.1.6): 8-64 caracteres con al menos una letra y un número. */
final class PasswordRules {

    static final String REGEX = "^(?=.*[A-Za-z])(?=.*\\d).{8,64}$";
    static final String MESSAGE = "La contraseña debe tener entre 8 y 64 caracteres, con al menos una letra y un número";

    private PasswordRules() {
    }
}
