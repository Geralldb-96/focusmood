package com.focusmood.wellness;

import java.time.LocalDate;

/** Estadísticas de bienestar para el módulo de progreso. */
public interface WellnessStats {

    int completedActivities(Long userId, LocalDate from, LocalDate to);
}
