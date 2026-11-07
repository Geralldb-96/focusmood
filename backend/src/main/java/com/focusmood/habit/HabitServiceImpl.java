package com.focusmood.habit;

import com.focusmood.common.exception.BusinessRuleException;
import com.focusmood.common.exception.ConflictException;
import com.focusmood.common.exception.ResourceNotFoundException;
import com.focusmood.habit.dto.CompleteHabitRequest;
import com.focusmood.habit.dto.CompletionResponse;
import com.focusmood.habit.dto.HabitRequest;
import com.focusmood.habit.dto.HabitResponse;
import java.time.Clock;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
class HabitServiceImpl implements HabitService {

    private static final int DEFAULT_HISTORY_DAYS = 30;

    private final HabitRepository habits;
    private final HabitCompletionRepository completions;
    private final Clock clock;

    HabitServiceImpl(HabitRepository habits, HabitCompletionRepository completions, Clock clock) {
        this.habits = habits;
        this.completions = completions;
        this.clock = clock;
    }

    @Override
    @Transactional
    public HabitResponse create(Long userId, HabitRequest request) {
        Habit habit = new Habit(userId, request.name().trim(), blankToNull(request.description()),
                request.frequency(), request.schedule(), LocalDate.now(clock));
        if (Boolean.FALSE.equals(request.active())) {
            habit.update(habit.getName(), habit.getDescription(), habit.getFrequency(), habit.getSchedule(), false);
        }
        return HabitResponse.from(habits.save(habit), false);
    }

    @Override
    @Transactional
    public HabitResponse update(Long userId, Long habitId, HabitRequest request) {
        Habit habit = find(userId, habitId);
        boolean active = request.active() != null ? request.active() : habit.isActive();
        habit.update(request.name().trim(), blankToNull(request.description()), request.frequency(),
                request.schedule(), active);
        return HabitResponse.from(habit, completions.existsByHabitIdAndDate(habitId, LocalDate.now(clock)));
    }

    @Override
    @Transactional
    public void delete(Long userId, Long habitId) {
        habits.delete(find(userId, habitId));
    }

    @Override
    @Transactional(readOnly = true)
    public HabitResponse get(Long userId, Long habitId) {
        Habit habit = find(userId, habitId);
        return HabitResponse.from(habit, completions.existsByHabitIdAndDate(habitId, LocalDate.now(clock)));
    }

    @Override
    @Transactional(readOnly = true)
    public List<HabitResponse> list(Long userId, boolean activeOnly) {
        List<Habit> found = activeOnly
                ? habits.findByUserIdAndActiveTrueOrderByNameAsc(userId)
                : habits.findByUserIdOrderByNameAsc(userId);
        if (found.isEmpty()) {
            return List.of();
        }
        LocalDate today = LocalDate.now(clock);
        Set<Long> doneToday = completions
                .findByHabitIdInAndDateBetween(found.stream().map(Habit::getId).toList(), today, today).stream()
                .map(HabitCompletion::getHabitId)
                .collect(Collectors.toSet());
        return found.stream().map(h -> HabitResponse.from(h, doneToday.contains(h.getId()))).toList();
    }

    @Override
    @Transactional
    public CompletionResponse complete(Long userId, Long habitId, CompleteHabitRequest request) {
        Habit habit = find(userId, habitId);
        LocalDate today = LocalDate.now(clock);
        LocalDate date = request != null && request.date() != null ? request.date() : today;
        if (!habit.isActive()) {
            throw new BusinessRuleException("El hábito está desactivado. Actívalo para registrar su cumplimiento.");
        }
        if (date.isAfter(today)) {
            throw new BusinessRuleException("No puedes marcar un hábito en una fecha futura.");
        }
        if (date.isBefore(habit.getStartDate())) {
            throw new BusinessRuleException("La fecha es anterior al inicio del hábito.");
        }
        if (completions.existsByHabitIdAndDate(habitId, date)) {
            throw new ConflictException("Este hábito ya fue marcado como realizado en esa fecha.");
        }
        String note = request != null ? blankToNull(request.note()) : null;
        return CompletionResponse.from(completions.save(new HabitCompletion(habitId, date, note)));
    }

    @Override
    @Transactional
    public void undoCompletion(Long userId, Long habitId, LocalDate date) {
        find(userId, habitId);
        HabitCompletion completion = completions.findByHabitIdAndDate(habitId, date)
                .orElseThrow(() -> new ResourceNotFoundException("No hay un cumplimiento registrado en esa fecha."));
        completions.delete(completion);
    }

    @Override
    @Transactional(readOnly = true)
    public List<CompletionResponse> completions(Long userId, Long habitId, LocalDate from, LocalDate to) {
        find(userId, habitId);
        LocalDate end = to != null ? to : LocalDate.now(clock);
        LocalDate start = from != null ? from : end.minusDays(DEFAULT_HISTORY_DAYS);
        if (start.isAfter(end)) {
            throw new BusinessRuleException("La fecha inicial no puede ser posterior a la final.");
        }
        return completions.findByHabitIdAndDateBetweenOrderByDateDesc(habitId, start, end).stream()
                .map(CompletionResponse::from)
                .toList();
    }

    private Habit find(Long userId, Long habitId) {
        return habits.findByIdAndUserId(habitId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Hábito no encontrado."));
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
