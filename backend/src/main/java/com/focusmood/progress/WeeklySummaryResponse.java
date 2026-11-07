package com.focusmood.progress;

import com.focusmood.daily.MoodStats;
import com.focusmood.habit.HabitStats;
import com.focusmood.recommendation.RecommendationStats;
import com.focusmood.study.StudyStats;
import java.time.LocalDate;

/**
 * Resumen semanal calculado al vuelo (sección 4.3.3: no se persiste).
 *
 * @param hasData falso cuando no hay ningún registro en el periodo; en ese caso {@code message} lo explica
 *                y las secciones vienen vacías, sin cifras inventadas (FCM-15).
 */
public record WeeklySummaryResponse(
        LocalDate weekStart, LocalDate weekEnd, boolean hasData, String message,
        MoodStats.MoodSummary mood, HabitStats.HabitSummary habits, StudyStats.StudySummary study,
        int wellnessActivitiesCompleted, RecommendationStats.RecommendationSummary recommendations) {
}
