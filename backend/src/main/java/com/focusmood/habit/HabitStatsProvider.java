package com.focusmood.habit;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
class HabitStatsProvider implements HabitStats {

    private final HabitRepository habits;
    private final HabitCompletionRepository completions;

    HabitStatsProvider(HabitRepository habits, HabitCompletionRepository completions) {
        this.habits = habits;
        this.completions = completions;
    }

    @Override
    @Transactional(readOnly = true)
    public HabitSummary summary(Long userId, LocalDate from, LocalDate to) {
        List<Habit> active = habits.findByUserIdAndActiveTrueOrderByNameAsc(userId);
        if (active.isEmpty()) {
            return new HabitSummary(0, 0, 0, null, List.of());
        }
        Map<Long, Long> doneByHabit = completions
                .findByHabitIdInAndDateBetween(active.stream().map(Habit::getId).toList(), from, to).stream()
                .collect(Collectors.groupingBy(HabitCompletion::getHabitId, Collectors.counting()));

        List<Item> items = new ArrayList<>();
        int totalExpected = 0;
        int totalDone = 0;
        for (Habit habit : active) {
            LocalDate start = habit.getStartDate().isAfter(from) ? habit.getStartDate() : from;
            int expected = start.isAfter(to) ? 0 : habit.getFrequency().expectedBetween(start, to);
            int done = Math.min(doneByHabit.getOrDefault(habit.getId(), 0L).intValue(), Math.max(expected, 0));
            items.add(new Item(habit.getId(), habit.getName(), expected, done, rate(done, expected)));
            totalExpected += expected;
            totalDone += done;
        }
        return new HabitSummary(active.size(), totalExpected, totalDone, rate(totalDone, totalExpected), items);
    }

    private static Double rate(int done, int expected) {
        return expected == 0 ? null : Math.round(done * 1000.0 / expected) / 10.0;
    }
}
