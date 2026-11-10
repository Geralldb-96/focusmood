package com.focusmood.progress;

import java.time.LocalDate;

public interface WeeklySummaryService {

    /** @param anyDayOfWeek cualquier día de la semana deseada (lunes a domingo); {@code null} = semana actual. */
    WeeklySummaryResponse summary(Long userId, LocalDate anyDayOfWeek);
}
