package com.focusmood.habit;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDate;

@Entity
@Table(name = "cumplimiento_habito")
public class HabitCompletion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_cumplimiento")
    private Long id;

    @Column(name = "id_habito", nullable = false)
    private Long habitId;

    @Column(name = "fecha", nullable = false)
    private LocalDate date;

    @Column(name = "cumplido", nullable = false)
    private boolean done = true;

    @Column(name = "observacion", length = 500)
    private String note;

    protected HabitCompletion() {
    }

    public HabitCompletion(Long habitId, LocalDate date, String note) {
        this.habitId = habitId;
        this.date = date;
        this.note = note;
    }

    public Long getId() {
        return id;
    }

    public Long getHabitId() {
        return habitId;
    }

    public LocalDate getDate() {
        return date;
    }

    public boolean isDone() {
        return done;
    }

    public String getNote() {
        return note;
    }
}
