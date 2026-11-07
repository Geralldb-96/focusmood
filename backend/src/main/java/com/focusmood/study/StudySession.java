package com.focusmood.study;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "sesion_estudio")
public class StudySession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_sesion")
    private Long id;

    @Column(name = "id_usuario", nullable = false)
    private Long userId;

    @Column(name = "fecha_inicio", nullable = false)
    private Instant startedAt;

    @Column(name = "fecha_fin")
    private Instant endedAt;

    @Column(name = "actividad", nullable = false, length = 200)
    private String activity;

    @Column(name = "duracion_minutos", nullable = false)
    private int durationMinutes;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado", nullable = false, length = 20)
    private SessionStatus status;

    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @JoinColumn(name = "id_sesion", nullable = false)
    private List<PomodoroCycle> cycles = new ArrayList<>();

    protected StudySession() {
    }

    public StudySession(Long userId, Instant startedAt, Instant endedAt, String activity, int durationMinutes,
                        SessionStatus status) {
        this.userId = userId;
        this.startedAt = startedAt;
        this.endedAt = endedAt;
        this.activity = activity;
        this.durationMinutes = durationMinutes;
        this.status = status;
    }

    public void addCycle(PomodoroCycle cycle) {
        cycles.add(cycle);
    }

    public Long getId() {
        return id;
    }

    public Long getUserId() {
        return userId;
    }

    public Instant getStartedAt() {
        return startedAt;
    }

    public Instant getEndedAt() {
        return endedAt;
    }

    public String getActivity() {
        return activity;
    }

    public int getDurationMinutes() {
        return durationMinutes;
    }

    public SessionStatus getStatus() {
        return status;
    }

    public List<PomodoroCycle> getCycles() {
        return cycles;
    }
}
