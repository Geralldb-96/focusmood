package com.focusmood.reminder.dto;

import com.focusmood.reminder.Reminder;
import com.focusmood.reminder.ReminderFrequency;
import com.focusmood.reminder.ReminderType;
import java.time.Instant;

public record ReminderResponse(
        Long id, String title, ReminderType type, Long habitId, Instant scheduledAt, ReminderFrequency frequency,
        boolean active) {

    public static ReminderResponse from(Reminder r) {
        return new ReminderResponse(r.getId(), r.getTitle(), r.getType(), r.getHabitId(), r.getScheduledAt(),
                r.getFrequency(), r.isActive());
    }
}
