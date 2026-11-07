package com.focusmood.wellness;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
class WellnessStatsProvider implements WellnessStats {

    private final WellnessLogRepository logs;
    private final Clock clock;

    WellnessStatsProvider(WellnessLogRepository logs, Clock clock) {
        this.logs = logs;
        this.clock = clock;
    }

    @Override
    @Transactional(readOnly = true)
    public int completedActivities(Long userId, LocalDate from, LocalDate to) {
        Instant lower = from.atStartOfDay(clock.getZone()).toInstant();
        Instant upper = to.plusDays(1).atStartOfDay(clock.getZone()).toInstant();
        return (int) logs.countByUserIdAndCompletedTrueAndPerformedAtGreaterThanEqualAndPerformedAtLessThan(
                userId, lower, upper);
    }
}
