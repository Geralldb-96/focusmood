package com.focusmood.wellness.dto;

import com.focusmood.wellness.WellnessActivity;
import com.focusmood.wellness.WellnessCategory;

public record WellnessActivityResponse(
        Long id, String name, String description, WellnessCategory category, int estimatedMinutes) {

    public static WellnessActivityResponse from(WellnessActivity a) {
        return new WellnessActivityResponse(a.getId(), a.getName(), a.getDescription(), a.getCategory(),
                a.getEstimatedMinutes());
    }
}
