package com.focusmood.daily;

import java.time.LocalDate;
import java.util.List;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
class DailyLogStatsProvider implements MoodStats {

    private final DailyLogRepository logs;

    DailyLogStatsProvider(DailyLogRepository logs) {
        this.logs = logs;
    }

    @Override
    @Transactional(readOnly = true)
    public MoodSummary summary(Long userId, LocalDate from, LocalDate to) {
        List<Point> points = logs.findByUserIdAndDateBetweenOrderByDateAsc(userId, from, to).stream()
                .map(l -> new Point(l.getDate(), l.getMood(), l.getMood().score(), l.getEnergyLevel(),
                        l.getConcentrationLevel()))
                .toList();
        if (points.isEmpty()) {
            return new MoodSummary(0, null, null, null, points);
        }
        return new MoodSummary(points.size(),
                average(points.stream().mapToInt(Point::moodScore).average().orElse(0)),
                average(points.stream().mapToInt(Point::energyLevel).average().orElse(0)),
                average(points.stream().mapToInt(Point::concentrationLevel).average().orElse(0)),
                points);
    }

    private static double average(double value) {
        return Math.round(value * 10.0) / 10.0;
    }
}
