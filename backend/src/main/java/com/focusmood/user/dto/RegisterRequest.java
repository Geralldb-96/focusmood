package com.focusmood.user.dto;

import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        @NotBlank(message = "El nombre es obligatorio") @Size(max = 120) String name,
        @NotBlank(message = "El correo es obligatorio") @Email(message = "El correo no tiene un formato válido") @Size(max = 150) String email,
        @NotBlank(message = "La contraseña es obligatoria")
        @Pattern(regexp = PasswordRules.REGEX, message = PasswordRules.MESSAGE) String password,
        @NotBlank(message = "Confirma tu contraseña") String confirmPassword,
        boolean acceptTerms) {

    @AssertTrue(message = "Las contraseñas no coinciden")
    boolean isPasswordConfirmed() {
        return password == null || password.equals(confirmPassword);
    }

    @AssertTrue(message = "Debes aceptar las condiciones de uso")
    boolean isTermsAccepted() {
        return acceptTerms;
    }
}
