package com.focusmood.habit.dto;

import com.focusmood.habit.Habit;
import com.focusmood.habit.HabitFrequency;
import com.focusmood.habit.HabitSchedule;
import java.time.LocalDate;

public record HabitResponse(
        Long id, String name, String description, HabitFrequency frequency, HabitSchedule schedule,
        LocalDate startDate, boolean active, boolean completedToday) {

    public static HabitResponse from(Habit habit, boolean completedToday) {
        return new HabitResponse(habit.getId(), habit.getName(), habit.getDescription(), habit.getFrequency(),
                habit.getSchedule(), habit.getStartDate(), habit.isActive(), completedToday);
    }
}
