package com.focusmood.study;

import com.focusmood.common.web.CurrentUserId;
import com.focusmood.study.dto.StudySessionRequest;
import com.focusmood.study.dto.StudySessionResponse;
import jakarta.validation.Valid;
import java.time.LocalDate;
import java.util.List;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/study-sessions")
class StudySessionController {

    private final StudySessionService service;

    StudySessionController(StudySessionService service) {
        this.service = service;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    StudySessionResponse record(@CurrentUserId Long userId, @Valid @RequestBody StudySessionRequest request) {
        return service.record(userId, request);
    }

    @GetMapping
    List<StudySessionResponse> history(@CurrentUserId Long userId,
                                       @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                                       @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return service.history(userId, from, to);
    }

    @GetMapping("/{id}")
    StudySessionResponse get(@CurrentUserId Long userId, @PathVariable Long id) {
        return service.get(userId, id);
    }
}
