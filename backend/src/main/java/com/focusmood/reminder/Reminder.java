package com.focusmood.reminder;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Version;
import java.time.Instant;

/**
 * Configuración de un recordatorio. El aviso se programa como notificación local en el dispositivo
 * (Capacitor); el backend solo conserva la configuración (sección 4.2).
 */
@Entity
@Table(name = "recordatorio")
public class Reminder {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_recordatorio")
    private Long id;

    @Version
    @Column(name = "version", nullable = false)
    private long version;

    @Column(name = "id_usuario", nullable = false)
    private Long userId;

    @Column(name = "id_habito")
    private Long habitId;

    @Column(name = "titulo", nullable = false, length = 120)
    private String title;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", nullable = false, length = 30)
    private ReminderType type;

    @Column(name = "fecha_hora", nullable = false)
    private Instant scheduledAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "frecuencia", length = 30)
    private ReminderFrequency frequency;

    @Column(name = "activo", nullable = false)
    private boolean active = true;

    protected Reminder() {
    }

    public Reminder(Long userId, Long habitId, String title, ReminderType type, Instant scheduledAt,
                    ReminderFrequency frequency, boolean active) {
        this.userId = userId;
        this.habitId = habitId;
        this.title = title;
        this.type = type;
        this.scheduledAt = scheduledAt;
        this.frequency = frequency;
        this.active = active;
    }

    public Long getId() {
        return id;
    }

    public Long getUserId() {
        return userId;
    }

    public Long getHabitId() {
        return habitId;
    }

    public String getTitle() {
        return title;
    }

    public ReminderType getType() {
        return type;
    }

    public Instant getScheduledAt() {
        return scheduledAt;
    }

    public ReminderFrequency getFrequency() {
        return frequency;
    }

    public boolean isActive() {
        return active;
    }

    public void update(Long habitId, String title, ReminderType type, Instant scheduledAt,
                       ReminderFrequency frequency, boolean active) {
        this.habitId = habitId;
        this.title = title;
        this.type = type;
        this.scheduledAt = scheduledAt;
        this.frequency = frequency;
        this.active = active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}
