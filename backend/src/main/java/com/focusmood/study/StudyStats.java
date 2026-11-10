package com.focusmood.study;

import java.time.LocalDate;

/** Estadísticas de estudio para el módulo de progreso. */
public interface StudyStats {

    StudySummary summary(Long userId, LocalDate from, LocalDate to);

    record StudySummary(int sessions, int totalMinutes, int completedCycles) {
    }
}
