package com.focusmood.wellness.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/** @param completed opcional; por defecto verdadero. */
public record WellnessLogRequest(
        @NotNull(message = "Selecciona la actividad") Long activityId,
        Boolean completed,
        @Size(max = 500) String note) {
}
