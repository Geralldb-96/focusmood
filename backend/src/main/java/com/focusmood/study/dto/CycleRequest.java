package com.focusmood.study.dto;

import com.focusmood.study.SessionStatus;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record CycleRequest(
        @NotNull @Min(value = 1, message = "La concentración debe ser mayor que cero") @Max(180) Integer focusMinutes,
        @NotNull @Min(value = 1, message = "El descanso debe ser mayor que cero") @Max(60) Integer breakMinutes,
        @NotNull @Min(0) @Max(50) Integer completedCycles,
        @NotNull SessionStatus status) {
}
