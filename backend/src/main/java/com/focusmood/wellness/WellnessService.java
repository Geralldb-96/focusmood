package com.focusmood.wellness;

import com.focusmood.wellness.dto.WellnessActivityResponse;
import com.focusmood.wellness.dto.WellnessLogRequest;
import com.focusmood.wellness.dto.WellnessLogResponse;
import java.time.LocalDate;
import java.util.List;

/** Catálogo de actividades de bienestar y su registro (FCM-14). */
public interface WellnessService {

    List<WellnessActivityResponse> activities(WellnessCategory category);

    WellnessActivityResponse activity(Long activityId);

    WellnessLogResponse log(Long userId, WellnessLogRequest request);

    List<WellnessLogResponse> history(Long userId, LocalDate from, LocalDate to);
}
