package com.focusmood.recommendation;

import com.focusmood.daily.DailyLog;
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

/** Solicitud de recomendación (tabla solicitud_recomendacion): tiempo y actividad sobre un registro diario. */
@Entity
@Table(name = "solicitud_recomendacion")
public class RecommendationRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_solicitud")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_registro", nullable = false)
    private DailyLog dailyLog;

    @Column(name = "fecha_hora", nullable = false)
    private Instant requestedAt;

    @Column(name = "tiempo_disponible", nullable = false)
    private int availableMinutes;

    @Column(name = "actividad_academica", nullable = false, length = 200)
    private String academicActivity;

    protected RecommendationRequest() {
    }

    public RecommendationRequest(DailyLog dailyLog, Instant requestedAt, int availableMinutes, String academicActivity) {
        this.dailyLog = dailyLog;
        this.requestedAt = requestedAt;
        this.availableMinutes = availableMinutes;
        this.academicActivity = academicActivity;
    }

    public Long getId() {
        return id;
    }

    public DailyLog getDailyLog() {
        return dailyLog;
    }

    public Instant getRequestedAt() {
        return requestedAt;
    }

    public int getAvailableMinutes() {
        return availableMinutes;
    }

    public String getAcademicActivity() {
        return academicActivity;
    }
}
