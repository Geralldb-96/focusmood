package com.focusmood.reminder.dto;

import jakarta.validation.constraints.NotNull;

public record ReminderActiveRequest(@NotNull(message = "Indica si el recordatorio está activo") Boolean active) {
}
