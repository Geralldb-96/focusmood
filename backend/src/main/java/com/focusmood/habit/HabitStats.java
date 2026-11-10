package com.focusmood.habit;

import java.time.LocalDate;
import java.util.List;

/** Estadísticas de hábitos para el módulo de progreso (RF-16, RF-23). */
public interface HabitStats {

    HabitSummary summary(Long userId, LocalDate from, LocalDate to);

    record HabitSummary(int activeHabits, int expected, int completed, Double completionRate, List<Item> items) {
    }

    record Item(Long habitId, String name, int expected, int completed, Double completionRate) {
    }
}
