package com.focusmood.user.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UpdateProfileRequest(
        @NotBlank(message = "El nombre es obligatorio") @Size(max = 120) String name,
        @Size(max = 120) String career,
        @Min(value = 1, message = "El semestre debe estar entre 1 y 20") @Max(value = 20, message = "El semestre debe estar entre 1 y 20") Integer semester,
        @Size(max = 2000) String preferences,
        @Size(max = 500) String photoUrl) {
}
