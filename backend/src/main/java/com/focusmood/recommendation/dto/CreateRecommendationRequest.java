package com.focusmood.recommendation.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CreateRecommendationRequest(
        @NotNull(message = "Indica el registro diario de referencia") Long dailyLogId,
        @NotNull(message = "Indica el tiempo disponible") @Min(value = 1, message = "El tiempo disponible debe ser mayor que cero") @Max(value = 480, message = "El tiempo disponible máximo es de 480 minutos") Integer availableMinutes,
        @NotBlank(message = "Indica la actividad académica") @Size(max = 200, message = "La actividad admite hasta 200 caracteres") String academicActivity) {
}
