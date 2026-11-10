package com.focusmood.daily.dto;

import com.focusmood.daily.DailyLog;
import com.focusmood.daily.Mood;
import java.time.Instant;
import java.time.LocalDate;

public record DailyLogResponse(
        Long id, LocalDate date, Instant recordedAt, Mood mood, int energyLevel, int concentrationLevel, String note) {

    public static DailyLogResponse from(DailyLog log) {
        return new DailyLogResponse(log.getId(), log.getDate(), log.getRecordedAt(), log.getMood(),
                log.getEnergyLevel(), log.getConcentrationLevel(), log.getNote());
    }
}
