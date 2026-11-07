package com.focusmood.wellness;

import com.focusmood.common.web.CurrentUserId;
import com.focusmood.wellness.dto.WellnessActivityResponse;
import com.focusmood.wellness.dto.WellnessLogRequest;
import com.focusmood.wellness.dto.WellnessLogResponse;
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
@RequestMapping("/api/v1/wellness")
class WellnessController {

    private final WellnessService service;

    WellnessController(WellnessService service) {
        this.service = service;
    }

    @GetMapping("/activities")
    List<WellnessActivityResponse> activities(@RequestParam(required = false) WellnessCategory category) {
        return service.activities(category);
    }

    @GetMapping("/activities/{id}")
    WellnessActivityResponse activity(@PathVariable Long id) {
        return service.activity(id);
    }

    @PostMapping("/logs")
    @ResponseStatus(HttpStatus.CREATED)
    WellnessLogResponse log(@CurrentUserId Long userId, @Valid @RequestBody WellnessLogRequest request) {
        return service.log(userId, request);
    }

    @GetMapping("/logs")
    List<WellnessLogResponse> history(@CurrentUserId Long userId,
                                      @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                                      @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return service.history(userId, from, to);
    }
}
