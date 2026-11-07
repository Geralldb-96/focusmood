package com.focusmood.wellness;

import java.time.Instant;
import java.util.List;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

public interface WellnessLogRepository extends JpaRepository<WellnessLog, Long> {

    @EntityGraph(attributePaths = "activity")
    List<WellnessLog> findByUserIdAndPerformedAtGreaterThanEqualAndPerformedAtLessThanOrderByPerformedAtDesc(
            Long userId, Instant from, Instant to);

    long countByUserIdAndCompletedTrueAndPerformedAtGreaterThanEqualAndPerformedAtLessThan(
            Long userId, Instant from, Instant to);
}
