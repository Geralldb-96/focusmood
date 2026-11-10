package com.focusmood.study.dto;

import com.focusmood.study.SessionStatus;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;

/** Sesión finalizada en el temporizador del dispositivo (FCM-13). */
public record StudySessionRequest(
        @NotNull(message = "Indica cuándo empezó la sesión") Instant startedAt,
        Instant endedAt,
        @NotBlank(message = "Indica la actividad realizada") @Size(max = 200) String activity,
        @NotNull @Min(value = 1, message = "La duración debe ser mayor que cero") @Max(value = 720, message = "La duración máxima es de 720 minutos") Integer durationMinutes,
        @NotNull SessionStatus status,
        @Valid @Size(max = 20, message = "Máximo 20 configuraciones de ciclo") List<CycleRequest> cycles) {
}
