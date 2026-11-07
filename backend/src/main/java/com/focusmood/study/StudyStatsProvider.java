package com.focusmood.study;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
class StudyStatsProvider implements StudyStats {

    private final StudySessionRepository sessions;
    private final Clock clock;

    StudyStatsProvider(StudySessionRepository sessions, Clock clock) {
        this.sessions = sessions;
        this.clock = clock;
    }

    @Override
    @Transactional(readOnly = true)
    public StudySummary summary(Long userId, LocalDate from, LocalDate to) {
        Instant lower = from.atStartOfDay(clock.getZone()).toInstant();
        Instant upper = to.plusDays(1).atStartOfDay(clock.getZone()).toInstant();
        List<StudySession> found = sessions
                .findByUserIdAndStartedAtGreaterThanEqualAndStartedAtLessThanOrderByStartedAtDesc(userId, lower, upper);
        int minutes = found.stream().mapToInt(StudySession::getDurationMinutes).sum();
        int cycles = found.stream().flatMap(s -> s.getCycles().stream()).mapToInt(PomodoroCycle::getCompletedCycles).sum();
        return new StudySummary(found.size(), minutes, cycles);
    }
}
