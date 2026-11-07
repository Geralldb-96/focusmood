package com.focusmood.daily;

import com.focusmood.daily.dto.DailyLogRequest;
import com.focusmood.daily.dto.DailyLogResponse;
import java.time.LocalDate;
import java.util.List;

/** Registro diario de ánimo, energía y concentración (FCM-05). */
public interface DailyLogService {

    DailyLogResponse create(Long userId, DailyLogRequest request);

    DailyLogResponse update(Long userId, Long logId, DailyLogRequest request);

    DailyLogResponse get(Long userId, Long logId);

    DailyLogResponse today(Long userId);

    List<DailyLogResponse> history(Long userId, LocalDate from, LocalDate to);
}
