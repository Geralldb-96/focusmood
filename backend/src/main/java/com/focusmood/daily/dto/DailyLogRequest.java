package com.focusmood.daily.dto;

import com.focusmood.daily.Mood;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;

/** @param date opcional; por defecto es hoy en la zona horaria de la aplicación. */
public record DailyLogRequest(
        @NotNull(message = "Selecciona tu estado de ánimo") Mood mood,
        @NotNull(message = "Indica tu nivel de energía") @Min(value = 1, message = "La energía va de 1 a 5") @Max(value = 5, message = "La energía va de 1 a 5") Integer energyLevel,
        @NotNull(message = "Indica tu nivel de concentración") @Min(value = 1, message = "La concentración va de 1 a 5") @Max(value = 5, message = "La concentración va de 1 a 5") Integer concentrationLevel,
        @Size(max = 500, message = "La observación admite hasta 500 caracteres") String note,
        LocalDate date) {
}
