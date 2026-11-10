package com.focusmood.daily;

import java.time.LocalDate;
import java.util.List;

/** Consulta agregada del registro diario, consumida por el módulo de progreso (depende de la abstracción). */
public interface MoodStats {

    MoodSummary summary(Long userId, LocalDate from, LocalDate to);

    record MoodSummary(int entries, Double averageMood, Double averageEnergy, Double averageConcentration,
                       List<Point> points) {
    }

    record Point(LocalDate date, Mood mood, int moodScore, int energyLevel, int concentrationLevel) {
    }
}
