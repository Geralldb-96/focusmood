package com.focusmood.reminder;

import com.focusmood.common.web.CurrentUserId;
import com.focusmood.reminder.dto.ReminderActiveRequest;
import com.focusmood.reminder.dto.ReminderRequest;
import com.focusmood.reminder.dto.ReminderResponse;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/reminders")
class ReminderController {

    private final ReminderService service;

    ReminderController(ReminderService service) {
        this.service = service;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    ReminderResponse create(@CurrentUserId Long userId, @Valid @RequestBody ReminderRequest request) {
        return service.create(userId, request);
    }

    @GetMapping
    List<ReminderResponse> list(@CurrentUserId Long userId) {
        return service.list(userId);
    }

    @GetMapping("/{id}")
    ReminderResponse get(@CurrentUserId Long userId, @PathVariable Long id) {
        return service.get(userId, id);
    }

    @PutMapping("/{id}")
    ReminderResponse update(@CurrentUserId Long userId, @PathVariable Long id,
                            @Valid @RequestBody ReminderRequest request) {
        return service.update(userId, id, request);
    }

    @PatchMapping("/{id}/active")
    ReminderResponse setActive(@CurrentUserId Long userId, @PathVariable Long id,
                               @Valid @RequestBody ReminderActiveRequest request) {
        return service.setActive(userId, id, request.active());
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void delete(@CurrentUserId Long userId, @PathVariable Long id) {
        service.delete(userId, id);
    }
}
