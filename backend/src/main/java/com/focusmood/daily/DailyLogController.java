package com.focusmood.daily;

import com.focusmood.common.web.CurrentUserId;
import com.focusmood.daily.dto.DailyLogRequest;
import com.focusmood.daily.dto.DailyLogResponse;
import jakarta.validation.Valid;
import java.time.LocalDate;
import java.util.List;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/daily-logs")
class DailyLogController {

    private final DailyLogService service;

    DailyLogController(DailyLogService service) {
        this.service = service;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    DailyLogResponse create(@CurrentUserId Long userId, @Valid @RequestBody DailyLogRequest request) {
        return service.create(userId, request);
    }

    @GetMapping
    List<DailyLogResponse> history(@CurrentUserId Long userId,
                                   @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                                   @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return service.history(userId, from, to);
    }

    @GetMapping("/today")
    DailyLogResponse today(@CurrentUserId Long userId) {
        return service.today(userId);
    }

    @GetMapping("/{id}")
    DailyLogResponse get(@CurrentUserId Long userId, @PathVariable Long id) {
        return service.get(userId, id);
    }

    @PutMapping("/{id}")
    DailyLogResponse update(@CurrentUserId Long userId, @PathVariable Long id,
                            @Valid @RequestBody DailyLogRequest request) {
        return service.update(userId, id, request);
    }
}
