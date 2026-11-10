package com.focusmood.study;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "ciclo_pomodoro")
public class PomodoroCycle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_pomodoro")
    private Long id;

    @Column(name = "duracion_concentracion", nullable = false)
    private int focusMinutes;

    @Column(name = "duracion_descanso", nullable = false)
    private int breakMinutes;

    @Column(name = "ciclos_completados", nullable = false)
    private int completedCycles;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado", nullable = false, length = 20)
    private SessionStatus status;

    protected PomodoroCycle() {
    }

    public PomodoroCycle(int focusMinutes, int breakMinutes, int completedCycles, SessionStatus status) {
        this.focusMinutes = focusMinutes;
        this.breakMinutes = breakMinutes;
        this.completedCycles = completedCycles;
        this.status = status;
    }

    public Long getId() {
        return id;
    }

    public int getFocusMinutes() {
        return focusMinutes;
    }

    public int getBreakMinutes() {
        return breakMinutes;
    }

    public int getCompletedCycles() {
        return completedCycles;
    }

    public SessionStatus getStatus() {
        return status;
    }
}
