package com.focusmood.progress;

import com.focusmood.daily.MoodStats;
import com.focusmood.habit.HabitStats;
import com.focusmood.recommendation.RecommendationStats;
import com.focusmood.study.StudyStats;
import com.focusmood.wellness.WellnessStats;
import java.time.Clock;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import org.springframework.stereotype.Service;

/** Ensambla el resumen consultando únicamente las abstracciones de estadísticas de cada módulo (DIP). */
@Service
class WeeklySummaryServiceImpl implements WeeklySummaryService {

    private static final String EMPTY_MESSAGE =
            "Todavía no hay registros en esta semana. Registra tu día, completa un hábito o inicia una sesión de estudio.";

    private final MoodStats moodStats;
    private final HabitStats habitStats;
    private final StudyStats studyStats;
    private final WellnessStats wellnessStats;
    private final RecommendationStats recommendationStats;
    private final Clock clock;

    WeeklySummaryServiceImpl(MoodStats moodStats, HabitStats habitStats, StudyStats studyStats,
                             WellnessStats wellnessStats, RecommendationStats recommendationStats, Clock clock) {
        this.moodStats = moodStats;
        this.habitStats = habitStats;
        this.studyStats = studyStats;
        this.wellnessStats = wellnessStats;
        this.recommendationStats = recommendationStats;
        this.clock = clock;
    }

    @Override
    public WeeklySummaryResponse summary(Long userId, LocalDate anyDayOfWeek) {
        LocalDate reference = anyDayOfWeek != null ? anyDayOfWeek : LocalDate.now(clock);
        LocalDate start = reference.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate end = start.plusDays(6);

        MoodStats.MoodSummary mood = moodStats.summary(userId, start, end);
        HabitStats.HabitSummary habits = habitStats.summary(userId, start, end);
        StudyStats.StudySummary study = studyStats.summary(userId, start, end);
        int wellness = wellnessStats.completedActivities(userId, start, end);
        RecommendationStats.RecommendationSummary recommendations = recommendationStats.summary(userId, start, end);

        boolean hasData = mood.entries() > 0 || habits.completed() > 0 || study.sessions() > 0
                || wellness > 0 || recommendations.generated() > 0;
        return new WeeklySummaryResponse(start, end, hasData, hasData ? null : EMPTY_MESSAGE, mood, habits, study,
                wellness, recommendations);
    }
}
