package com.focusmood.habit.dto;

import com.focusmood.habit.HabitCompletion;
import java.time.LocalDate;

public record CompletionResponse(Long id, Long habitId, LocalDate date, String note) {

    public static CompletionResponse from(HabitCompletion c) {
        return new CompletionResponse(c.getId(), c.getHabitId(), c.getDate(), c.getNote());
    }
}
