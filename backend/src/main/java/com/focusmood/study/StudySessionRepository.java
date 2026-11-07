package com.focusmood.study;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StudySessionRepository extends JpaRepository<StudySession, Long> {

    boolean existsByUserIdAndStartedAt(Long userId, Instant startedAt);

    @EntityGraph(attributePaths = "cycles")
    Optional<StudySession> findByIdAndUserId(Long id, Long userId);

    @EntityGraph(attributePaths = "cycles")
    List<StudySession> findByUserIdAndStartedAtGreaterThanEqualAndStartedAtLessThanOrderByStartedAtDesc(
            Long userId, Instant from, Instant to);
}
