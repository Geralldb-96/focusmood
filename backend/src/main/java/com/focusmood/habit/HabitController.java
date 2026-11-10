package com.focusmood.habit;

import com.focusmood.common.web.CurrentUserId;
import com.focusmood.habit.dto.CompleteHabitRequest;
import com.focusmood.habit.dto.CompletionResponse;
import com.focusmood.habit.dto.HabitRequest;
import com.focusmood.habit.dto.HabitResponse;
import jakarta.validation.Valid;
import java.time.LocalDate;
import java.util.List;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
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
@RequestMapping("/api/v1/habits")
class HabitController {

    private final HabitService service;

    HabitController(HabitService service) {
        this.service = service;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    HabitResponse create(@CurrentUserId Long userId, @Valid @RequestBody HabitRequest request) {
        return service.create(userId, request);
    }

    @GetMapping
    List<HabitResponse> list(@CurrentUserId Long userId, @RequestParam(defaultValue = "false") boolean activeOnly) {
        return service.list(userId, activeOnly);
    }

    @GetMapping("/{id}")
    HabitResponse get(@CurrentUserId Long userId, @PathVariable Long id) {
        return service.get(userId, id);
    }

    @PutMapping("/{id}")
    HabitResponse update(@CurrentUserId Long userId, @PathVariable Long id, @Valid @RequestBody HabitRequest request) {
        return service.update(userId, id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void delete(@CurrentUserId Long userId, @PathVariable Long id) {
        service.delete(userId, id);
    }

    @PostMapping("/{id}/completions")
    @ResponseStatus(HttpStatus.CREATED)
    CompletionResponse complete(@CurrentUserId Long userId, @PathVariable Long id,
                                @Valid @RequestBody(required = false) CompleteHabitRequest request) {
        return service.complete(userId, id, request);
    }

    @DeleteMapping("/{id}/completions/{date}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void undo(@CurrentUserId Long userId, @PathVariable Long id,
              @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        service.undoCompletion(userId, id, date);
    }

    @GetMapping("/{id}/completions")
    List<CompletionResponse> completions(@CurrentUserId Long userId, @PathVariable Long id,
                                         @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                                         @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return service.completions(userId, id, from, to);
    }
}
