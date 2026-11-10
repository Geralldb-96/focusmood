package com.focusmood.habit;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface HabitRepository extends JpaRepository<Habit, Long> {

    Optional<Habit> findByIdAndUserId(Long id, Long userId);

    List<Habit> findByUserIdOrderByNameAsc(Long userId);

    List<Habit> findByUserIdAndActiveTrueOrderByNameAsc(Long userId);
}
