package com.focusmood.user.dto;

import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record ResetPasswordRequest(
        @NotBlank(message = "El token es obligatorio") String token,
        @NotBlank(message = "La contraseña es obligatoria")
        @Pattern(regexp = PasswordRules.REGEX, message = PasswordRules.MESSAGE) String newPassword,
        @NotBlank(message = "Confirma tu contraseña") String confirmPassword) {

    @AssertTrue(message = "Las contraseñas no coinciden")
    boolean isPasswordConfirmed() {
        return newPassword == null || newPassword.equals(confirmPassword);
    }
}
