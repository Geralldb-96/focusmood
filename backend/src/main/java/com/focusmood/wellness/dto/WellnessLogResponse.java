package com.focusmood.wellness.dto;

import com.focusmood.wellness.WellnessLog;
import java.time.Instant;

public record WellnessLogResponse(
        Long id, Long activityId, String activityName, Instant performedAt, boolean completed, String note) {

    public static WellnessLogResponse from(WellnessLog l) {
        return new WellnessLogResponse(l.getId(), l.getActivity().getId(), l.getActivity().getName(),
                l.getPerformedAt(), l.isCompleted(), l.getNote());
    }
}
