package com.focusmood.habit.dto;

import com.focusmood.habit.HabitFrequency;
import com.focusmood.habit.HabitSchedule;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/** @param active opcional; por defecto verdadero al crear y se conserva el valor actual si se omite al editar. */
public record HabitRequest(
        @NotBlank(message = "El nombre del hábito es obligatorio") @Size(max = 100, message = "El nombre admite hasta 100 caracteres") String name,
        @Size(max = 500, message = "La descripción admite hasta 500 caracteres") String description,
        @NotNull(message = "Selecciona la frecuencia") HabitFrequency frequency,
        HabitSchedule schedule,
        Boolean active) {
}
