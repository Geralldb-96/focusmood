package com.focusmood.study.dto;

import com.focusmood.study.PomodoroCycle;
import com.focusmood.study.SessionStatus;
import com.focusmood.study.StudySession;
import java.time.Instant;
import java.util.List;

public record StudySessionResponse(
        Long id, Instant startedAt, Instant endedAt, String activity, int durationMinutes, SessionStatus status,
        int totalCompletedCycles, List<CycleResponse> cycles) {

    public record CycleResponse(Long id, int focusMinutes, int breakMinutes, int completedCycles, SessionStatus status) {

        static CycleResponse from(PomodoroCycle c) {
            return new CycleResponse(c.getId(), c.getFocusMinutes(), c.getBreakMinutes(), c.getCompletedCycles(),
                    c.getStatus());
        }
    }

    public static StudySessionResponse from(StudySession s) {
        List<CycleResponse> cycles = s.getCycles().stream().map(CycleResponse::from).toList();
        int total = s.getCycles().stream().mapToInt(PomodoroCycle::getCompletedCycles).sum();
        return new StudySessionResponse(s.getId(), s.getStartedAt(), s.getEndedAt(), s.getActivity(),
                s.getDurationMinutes(), s.getStatus(), total, cycles);
    }
}
