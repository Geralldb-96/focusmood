package com.focusmood.reminder;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReminderRepository extends JpaRepository<Reminder, Long> {

    Optional<Reminder> findByIdAndUserId(Long id, Long userId);

    List<Reminder> findByUserIdOrderByScheduledAtAsc(Long userId);
}
