package com.focusmood.study;

import com.focusmood.common.exception.BusinessRuleException;
import com.focusmood.common.exception.ConflictException;
import com.focusmood.common.exception.ResourceNotFoundException;
import com.focusmood.study.dto.CycleRequest;
import com.focusmood.study.dto.StudySessionRequest;
import com.focusmood.study.dto.StudySessionResponse;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
class StudySessionServiceImpl implements StudySessionService {

    private static final Duration CLOCK_SKEW = Duration.ofMinutes(5);
    private static final int DEFAULT_HISTORY_DAYS = 30;

    private final StudySessionRepository sessions;
    private final Clock clock;

    StudySessionServiceImpl(StudySessionRepository sessions, Clock clock) {
        this.sessions = sessions;
        this.clock = clock;
    }

    @Override
    @Transactional
    public StudySessionResponse record(Long userId, StudySessionRequest request) {
        validate(request);
        if (sessions.existsByUserIdAndStartedAt(userId, request.startedAt())) {
            throw new ConflictException("Esta sesión de estudio ya fue registrada.");
        }
        StudySession session = new StudySession(userId, request.startedAt(), request.endedAt(),
                request.activity().trim(), request.durationMinutes(), request.status());
        if (request.cycles() != null) {
            for (CycleRequest c : request.cycles()) {
                session.addCycle(new PomodoroCycle(c.focusMinutes(), c.breakMinutes(), c.completedCycles(), c.status()));
            }
        }
        return StudySessionResponse.from(sessions.save(session));
    }

    @Override
    @Transactional(readOnly = true)
    public StudySessionResponse get(Long userId, Long sessionId) {
        return sessions.findByIdAndUserId(sessionId, userId)
                .map(StudySessionResponse::from)
                .orElseThrow(() -> new ResourceNotFoundException("Sesión de estudio no encontrada."));
    }

    @Override
    @Transactional(readOnly = true)
    public List<StudySessionResponse> history(Long userId, LocalDate from, LocalDate to) {
        LocalDate end = to != null ? to : LocalDate.now(clock);
        LocalDate start = from != null ? from : end.minusDays(DEFAULT_HISTORY_DAYS);
        if (start.isAfter(end)) {
            throw new BusinessRuleException("La fecha inicial no puede ser posterior a la final.");
        }
        Instant lower = start.atStartOfDay(clock.getZone()).toInstant();
        Instant upper = end.plusDays(1).atStartOfDay(clock.getZone()).toInstant();
        return sessions
                .findByUserIdAndStartedAtGreaterThanEqualAndStartedAtLessThanOrderByStartedAtDesc(userId, lower, upper)
                .stream().map(StudySessionResponse::from).toList();
    }

    private void validate(StudySessionRequest request) {
        if (request.startedAt().isAfter(clock.instant().plus(CLOCK_SKEW))) {
            throw new BusinessRuleException("La sesión no puede comenzar en el futuro.");
        }
        if (request.endedAt() != null && request.endedAt().isBefore(request.startedAt())) {
            throw new BusinessRuleException("La sesión no puede terminar antes de comenzar.");
        }
    }
}
