package com.focusmood.habit;

import java.time.LocalDate;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface HabitCompletionRepository extends JpaRepository<HabitCompletion, Long> {

    boolean existsByHabitIdAndDate(Long habitId, LocalDate date);

    Optional<HabitCompletion> findByHabitIdAndDate(Long habitId, LocalDate date);

    List<HabitCompletion> findByHabitIdAndDateBetweenOrderByDateDesc(Long habitId, LocalDate from, LocalDate to);

    List<HabitCompletion> findByHabitIdInAndDateBetween(Collection<Long> habitIds, LocalDate from, LocalDate to);
}
