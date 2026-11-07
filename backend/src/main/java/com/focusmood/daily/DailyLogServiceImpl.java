package com.focusmood.daily;

import com.focusmood.common.exception.BusinessRuleException;
import com.focusmood.common.exception.ConflictException;
import com.focusmood.common.exception.ResourceNotFoundException;
import com.focusmood.daily.dto.DailyLogRequest;
import com.focusmood.daily.dto.DailyLogResponse;
import java.time.Clock;
import java.time.LocalDate;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
class DailyLogServiceImpl implements DailyLogService {

    private static final int DEFAULT_HISTORY_DAYS = 30;

    private final DailyLogRepository logs;
    private final Clock clock;

    DailyLogServiceImpl(DailyLogRepository logs, Clock clock) {
        this.logs = logs;
        this.clock = clock;
    }

    @Override
    @Transactional
    public DailyLogResponse create(Long userId, DailyLogRequest request) {
        LocalDate date = request.date() != null ? request.date() : LocalDate.now(clock);
        if (date.isAfter(LocalDate.now(clock))) {
            throw new BusinessRuleException("No puedes registrar un día futuro.");
        }
        if (logs.existsByUserIdAndDate(userId, date)) {
            throw new ConflictException("Ya registraste cómo te sientes en esa fecha. Puedes editar el registro existente.");
        }
        DailyLog saved = logs.save(new DailyLog(userId, date, clock.instant(), request.mood(),
                request.energyLevel(), request.concentrationLevel(), blankToNull(request.note())));
        return DailyLogResponse.from(saved);
    }

    @Override
    @Transactional
    public DailyLogResponse update(Long userId, Long logId, DailyLogRequest request) {
        DailyLog log = find(userId, logId);
        log.update(request.mood(), request.energyLevel(), request.concentrationLevel(),
                blankToNull(request.note()), clock.instant());
        return DailyLogResponse.from(log);
    }

    @Override
    @Transactional(readOnly = true)
    public DailyLogResponse get(Long userId, Long logId) {
        return DailyLogResponse.from(find(userId, logId));
    }

    @Override
    @Transactional(readOnly = true)
    public DailyLogResponse today(Long userId) {
        return logs.findByUserIdAndDate(userId, LocalDate.now(clock))
                .map(DailyLogResponse::from)
                .orElseThrow(() -> new ResourceNotFoundException("Aún no registras cómo te sientes hoy."));
    }

    @Override
    @Transactional(readOnly = true)
    public List<DailyLogResponse> history(Long userId, LocalDate from, LocalDate to) {
        LocalDate end = to != null ? to : LocalDate.now(clock);
        LocalDate start = from != null ? from : end.minusDays(DEFAULT_HISTORY_DAYS);
        if (start.isAfter(end)) {
            throw new BusinessRuleException("La fecha inicial no puede ser posterior a la final.");
        }
        return logs.findByUserIdAndDateBetweenOrderByDateDesc(userId, start, end).stream()
                .map(DailyLogResponse::from)
                .toList();
    }

    private DailyLog find(Long userId, Long logId) {
        return logs.findByIdAndUserId(logId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Registro diario no encontrado."));
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
