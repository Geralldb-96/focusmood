package com.focusmood.recommendation;

import java.time.LocalDate;

/** Estadísticas de recomendaciones para el módulo de progreso. */
public interface RecommendationStats {

    RecommendationSummary summary(Long userId, LocalDate from, LocalDate to);

    record RecommendationSummary(int generated, int rated, int helpful) {
    }
}
