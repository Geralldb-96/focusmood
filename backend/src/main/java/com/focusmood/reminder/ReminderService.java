package com.focusmood.reminder;

import com.focusmood.reminder.dto.ReminderRequest;
import com.focusmood.reminder.dto.ReminderResponse;
import java.util.List;

/** Configuración de recordatorios (FCM-16). */
public interface ReminderService {

    ReminderResponse create(Long userId, ReminderRequest request);

    ReminderResponse update(Long userId, Long reminderId, ReminderRequest request);

    ReminderResponse setActive(Long userId, Long reminderId, boolean active);

    void delete(Long userId, Long reminderId);

    ReminderResponse get(Long userId, Long reminderId);

    List<ReminderResponse> list(Long userId);
}
