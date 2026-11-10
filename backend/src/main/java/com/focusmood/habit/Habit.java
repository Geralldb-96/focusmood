package com.focusmood.habit;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Version;
import java.time.LocalDate;

@Entity
@Table(name = "habito")
public class Habit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_habito")
    private Long id;

    @Version
    @Column(name = "version", nullable = false)
    private long version;

    @Column(name = "id_usuario", nullable = false)
    private Long userId;

    @Column(name = "nombre", nullable = false, length = 100)
    private String name;

    @Column(name = "descripcion", length = 500)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "frecuencia", nullable = false, length = 30)
    private HabitFrequency frequency;

    @Enumerated(EnumType.STRING)
    @Column(name = "horario", length = 20)
    private HabitSchedule schedule;

    @Column(name = "fecha_inicio", nullable = false)
    private LocalDate startDate;

    @Column(name = "activo", nullable = false)
    private boolean active = true;

    protected Habit() {
    }

    public Habit(Long userId, String name, String description, HabitFrequency frequency, HabitSchedule schedule,
                 LocalDate startDate) {
        this.userId = userId;
        this.name = name;
        this.description = description;
        this.frequency = frequency;
        this.schedule = schedule;
        this.startDate = startDate;
    }

    public Long getId() {
        return id;
    }

    public Long getUserId() {
        return userId;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public HabitFrequency getFrequency() {
        return frequency;
    }

    public HabitSchedule getSchedule() {
        return schedule;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public boolean isActive() {
        return active;
    }

    public void update(String name, String description, HabitFrequency frequency, HabitSchedule schedule,
                       boolean active) {
        this.name = name;
        this.description = description;
        this.frequency = frequency;
        this.schedule = schedule;
        this.active = active;
    }
}
