package com.focusmood.habit.dto;

import jakarta.validation.constraints.Size;
import java.time.LocalDate;

/** @param date opcional; por defecto hoy. */
public record CompleteHabitRequest(LocalDate date, @Size(max = 500) String note) {
}
