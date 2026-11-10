package com.focusmood.habit;

import com.focusmood.habit.dto.CompleteHabitRequest;
import com.focusmood.habit.dto.CompletionResponse;
import com.focusmood.habit.dto.HabitRequest;
import com.focusmood.habit.dto.HabitResponse;
import java.time.LocalDate;
import java.util.List;

/** Gestión de hábitos y de su cumplimiento (FCM-10, FCM-11). */
public interface HabitService {

    HabitResponse create(Long userId, HabitRequest request);

    HabitResponse update(Long userId, Long habitId, HabitRequest request);

    void delete(Long userId, Long habitId);

    HabitResponse get(Long userId, Long habitId);

    List<HabitResponse> list(Long userId, boolean activeOnly);

    CompletionResponse complete(Long userId, Long habitId, CompleteHabitRequest request);

    void undoCompletion(Long userId, Long habitId, LocalDate date);

    List<CompletionResponse> completions(Long userId, Long habitId, LocalDate from, LocalDate to);
}
