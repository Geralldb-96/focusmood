package com.focusmood.daily;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DailyLogRepository extends JpaRepository<DailyLog, Long> {

    Optional<DailyLog> findByIdAndUserId(Long id, Long userId);

    Optional<DailyLog> findByUserIdAndDate(Long userId, LocalDate date);

    boolean existsByUserIdAndDate(Long userId, LocalDate date);

    List<DailyLog> findByUserIdAndDateBetweenOrderByDateDesc(Long userId, LocalDate from, LocalDate to);

    List<DailyLog> findByUserIdAndDateBetweenOrderByDateAsc(Long userId, LocalDate from, LocalDate to);
}
