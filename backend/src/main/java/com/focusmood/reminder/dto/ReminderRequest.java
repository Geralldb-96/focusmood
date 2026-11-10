package com.focusmood.reminder.dto;

import com.focusmood.reminder.ReminderFrequency;
import com.focusmood.reminder.ReminderType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;

/** @param habitId obligatorio cuando type = HABIT; en otros tipos se ignora. */
public record ReminderRequest(
        @NotBlank(message = "El título es obligatorio") @Size(max = 120) String title,
        @NotNull(message = "Selecciona el tipo de recordatorio") ReminderType type,
        Long habitId,
        @NotNull(message = "Indica la fecha y hora") Instant scheduledAt,
        @NotNull(message = "Selecciona la frecuencia") ReminderFrequency frequency,
        Boolean active) {
}
