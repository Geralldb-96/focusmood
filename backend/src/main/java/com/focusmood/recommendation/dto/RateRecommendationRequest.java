package com.focusmood.recommendation.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/** score 1-5. La app puede mapear "No me sirvió" a 1 y "Me sirvió" a 5. */
public record RateRecommendationRequest(
        @NotNull(message = "Indica la puntuación") @Min(value = 1, message = "La puntuación va de 1 a 5") @Max(value = 5, message = "La puntuación va de 1 a 5") Integer score,
        @Size(max = 500, message = "El comentario admite hasta 500 caracteres") String comment) {
}
