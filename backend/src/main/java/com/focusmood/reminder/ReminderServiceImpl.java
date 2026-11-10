package com.focusmood.reminder;

import com.focusmood.common.exception.BusinessRuleException;
import com.focusmood.common.exception.ResourceNotFoundException;
import com.focusmood.habit.HabitService;
import com.focusmood.reminder.dto.ReminderRequest;
import com.focusmood.reminder.dto.ReminderResponse;
import java.time.Clock;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
class ReminderServiceImpl implements ReminderService {

    private final ReminderRepository reminders;
    private final HabitService habits;
    private final Clock clock;

    ReminderServiceImpl(ReminderRepository reminders, HabitService habits, Clock clock) {
        this.reminders = reminders;
        this.habits = habits;
        this.clock = clock;
    }

    @Override
    @Transactional
    public ReminderResponse create(Long userId, ReminderRequest request) {
        Long habitId = resolveHabit(userId, request);
        validateSchedule(request);
        boolean active = request.active() == null || request.active();
        return ReminderResponse.from(reminders.save(new Reminder(userId, habitId, request.title().trim(),
                request.type(), request.scheduledAt(), request.frequency(), active)));
    }

    @Override
    @Transactional
    public ReminderResponse update(Long userId, Long reminderId, ReminderRequest request) {
        Reminder reminder = find(userId, reminderId);
        Long habitId = resolveHabit(userId, request);
        validateSchedule(request);
        boolean active = request.active() != null ? request.active() : reminder.isActive();
        reminder.update(habitId, request.title().trim(), request.type(), request.scheduledAt(),
                request.frequency(), active);
        return ReminderResponse.from(reminder);
    }

    @Override
    @Transactional
    public ReminderResponse setActive(Long userId, Long reminderId, boolean active) {
        Reminder reminder = find(userId, reminderId);
        reminder.setActive(active);
        return ReminderResponse.from(reminder);
    }

    @Override
    @Transactional
    public void delete(Long userId, Long reminderId) {
        reminders.delete(find(userId, reminderId));
    }

    @Override
    @Transactional(readOnly = true)
    public ReminderResponse get(Long userId, Long reminderId) {
        return ReminderResponse.from(find(userId, reminderId));
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReminderResponse> list(Long userId) {
        return reminders.findByUserIdOrderByScheduledAtAsc(userId).stream().map(ReminderResponse::from).toList();
    }

    /** Un recordatorio de hábito debe apuntar a un hábito del mismo usuario (RNF-07). */
    private Long resolveHabit(Long userId, ReminderRequest request) {
        if (request.type() != ReminderType.HABIT) {
            return null;
        }
        if (request.habitId() == null) {
            throw new BusinessRuleException("Selecciona el hábito que quieres recordar.");
        }
        habits.get(userId, request.habitId());
        return request.habitId();
    }

    private void validateSchedule(ReminderRequest request) {
        if (request.frequency() == ReminderFrequency.ONCE && !request.scheduledAt().isAfter(clock.instant())) {
            throw new BusinessRuleException("Un recordatorio único debe programarse en una fecha y hora futuras.");
        }
    }

    private Reminder find(Long userId, Long reminderId) {
        return reminders.findByIdAndUserId(reminderId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Recordatorio no encontrado."));
    }
}
