package com.focusmood.habit;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.LocalDate;
import org.junit.jupiter.api.Test;

class HabitFrequencyTest {

    // Lunes 2026-11-02 a domingo 2026-11-08
    private static final LocalDate MONDAY = LocalDate.of(2026, 11, 2);
    private static final LocalDate SUNDAY = LocalDate.of(2026, 11, 8);

    @Test
    void dailyExpectsOnePerDay() {
        assertThat(HabitFrequency.DAILY.expectedBetween(MONDAY, SUNDAY)).isEqualTo(7);
    }

    @Test
    void weekdaysSkipsWeekend() {
        assertThat(HabitFrequency.WEEKDAYS.expectedBetween(MONDAY, SUNDAY)).isEqualTo(5);
    }

    @Test
    void weeklyExpectsOnePerStartedWeek() {
        assertThat(HabitFrequency.WEEKLY.expectedBetween(MONDAY, SUNDAY)).isEqualTo(1);
        assertThat(HabitFrequency.WEEKLY.expectedBetween(MONDAY, MONDAY)).isEqualTo(1);
    }

    @Test
    void partialWeekRespectsStartDate() {
        assertThat(HabitFrequency.DAILY.expectedBetween(LocalDate.of(2026, 11, 6), SUNDAY)).isEqualTo(3);
    }
}
