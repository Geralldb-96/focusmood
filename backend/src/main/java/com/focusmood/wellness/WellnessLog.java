package com.focusmood.wellness;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;

@Entity
@Table(name = "registro_bienestar")
public class WellnessLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_registro_bienestar")
    private Long id;

    @Column(name = "id_usuario", nullable = false)
    private Long userId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_actividad", nullable = false)
    private WellnessActivity activity;

    @Column(name = "fecha_realizacion", nullable = false)
    private Instant performedAt;

    @Column(name = "completada", nullable = false)
    private boolean completed;

    @Column(name = "observacion", length = 500)
    private String note;

    protected WellnessLog() {
    }

    public WellnessLog(Long userId, WellnessActivity activity, Instant performedAt, boolean completed, String note) {
        this.userId = userId;
        this.activity = activity;
        this.performedAt = performedAt;
        this.completed = completed;
        this.note = note;
    }

    public Long getId() {
        return id;
    }

    public Long getUserId() {
        return userId;
    }

    public WellnessActivity getActivity() {
        return activity;
    }

    public Instant getPerformedAt() {
        return performedAt;
    }

    public boolean isCompleted() {
        return completed;
    }

    public String getNote() {
        return note;
    }
}
