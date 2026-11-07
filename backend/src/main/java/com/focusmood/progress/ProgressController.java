package com.focusmood.progress;

import com.focusmood.common.web.CurrentUserId;
import java.time.LocalDate;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/progress")
class ProgressController {

    private final WeeklySummaryService service;

    ProgressController(WeeklySummaryService service) {
        this.service = service;
    }

    @GetMapping("/weekly")
    WeeklySummaryResponse weekly(@CurrentUserId Long userId,
                                 @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return service.summary(userId, date);
    }
}
