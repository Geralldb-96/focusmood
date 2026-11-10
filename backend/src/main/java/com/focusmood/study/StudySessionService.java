package com.focusmood.study;

import com.focusmood.study.dto.StudySessionRequest;
import com.focusmood.study.dto.StudySessionResponse;
import java.time.LocalDate;
import java.util.List;

/** Registro y consulta de sesiones de estudio (FCM-13). El temporizador corre en el dispositivo (FCM-12). */
public interface StudySessionService {

    StudySessionResponse record(Long userId, StudySessionRequest request);

    StudySessionResponse get(Long userId, Long sessionId);

    List<StudySessionResponse> history(Long userId, LocalDate from, LocalDate to);
}
