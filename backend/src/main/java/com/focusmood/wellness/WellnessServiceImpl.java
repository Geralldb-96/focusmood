package com.focusmood.wellness;

import com.focusmood.common.exception.BusinessRuleException;
import com.focusmood.common.exception.ResourceNotFoundException;
import com.focusmood.wellness.dto.WellnessActivityResponse;
import com.focusmood.wellness.dto.WellnessLogRequest;
import com.focusmood.wellness.dto.WellnessLogResponse;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
class WellnessServiceImpl implements WellnessService {

    private static final int DEFAULT_HISTORY_DAYS = 30;

    private final WellnessActivityRepository activities;
    private final WellnessLogRepository logs;
    private final Clock clock;

    WellnessServiceImpl(WellnessActivityRepository activities, WellnessLogRepository logs, Clock clock) {
        this.activities = activities;
        this.logs = logs;
        this.clock = clock;
    }

    @Override
    @Transactional(readOnly = true)
    public List<WellnessActivityResponse> activities(WellnessCategory category) {
        List<WellnessActivity> found = category == null
                ? activities.findByActiveTrueOrderByNameAsc()
                : activities.findByActiveTrueAndCategoryOrderByNameAsc(category);
        return found.stream().map(WellnessActivityResponse::from).toList();
    }

    @Override
    @Transactional(readOnly = true)
    public WellnessActivityResponse activity(Long activityId) {
        return WellnessActivityResponse.from(find(activityId));
    }

    @Override
    @Transactional
    public WellnessLogResponse log(Long userId, WellnessLogRequest request) {
        WellnessActivity activity = find(request.activityId());
        boolean completed = request.completed() == null || request.completed();
        String note = request.note() == null || request.note().isBlank() ? null : request.note().trim();
        return WellnessLogResponse.from(logs.save(new WellnessLog(userId, activity, clock.instant(), completed, note)));
    }

    @Override
    @Transactional(readOnly = true)
    public List<WellnessLogResponse> history(Long userId, LocalDate from, LocalDate to) {
        LocalDate end = to != null ? to : LocalDate.now(clock);
        LocalDate start = from != null ? from : end.minusDays(DEFAULT_HISTORY_DAYS);
        if (start.isAfter(end)) {
            throw new BusinessRuleException("La fecha inicial no puede ser posterior a la final.");
        }
        Instant lower = start.atStartOfDay(clock.getZone()).toInstant();
        Instant upper = end.plusDays(1).atStartOfDay(clock.getZone()).toInstant();
        return logs.findByUserIdAndPerformedAtGreaterThanEqualAndPerformedAtLessThanOrderByPerformedAtDesc(
                userId, lower, upper).stream().map(WellnessLogResponse::from).toList();
    }

    private WellnessActivity find(Long id) {
        return activities.findByIdAndActiveTrue(id)
                .orElseThrow(() -> new ResourceNotFoundException("Actividad de bienestar no encontrada."));
    }
}
