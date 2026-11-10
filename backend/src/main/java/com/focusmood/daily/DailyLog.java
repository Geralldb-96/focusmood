package com.focusmood.daily;

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
import java.time.LocalDate;

@Entity
@Table(name = "registro_diario")
public class DailyLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_registro")
    private Long id;

    @Version
    @Column(name = "version", nullable = false)
    private long version;

    @Column(name = "id_usuario", nullable = false)
    private Long userId;

    @Column(name = "fecha", nullable = false)
    private LocalDate date;

    @Column(name = "fecha_hora", nullable = false)
    private Instant recordedAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado_animo", nullable = false, length = 30)
    private Mood mood;

    @Column(name = "nivel_energia", nullable = false)
    private int energyLevel;

    @Column(name = "nivel_concentracion", nullable = false)
    private int concentrationLevel;

    @Column(name = "observacion", length = 500)
    private String note;

    protected DailyLog() {
    }

    public DailyLog(Long userId, LocalDate date, Instant recordedAt, Mood mood, int energyLevel,
                    int concentrationLevel, String note) {
        this.userId = userId;
        this.date = date;
        this.recordedAt = recordedAt;
        this.mood = mood;
        this.energyLevel = energyLevel;
        this.concentrationLevel = concentrationLevel;
        this.note = note;
    }

    public Long getId() {
        return id;
    }

    public Long getUserId() {
        return userId;
    }

    public LocalDate getDate() {
        return date;
    }

    public Instant getRecordedAt() {
        return recordedAt;
    }

    public Mood getMood() {
        return mood;
    }

    public int getEnergyLevel() {
        return energyLevel;
    }

    public int getConcentrationLevel() {
        return concentrationLevel;
    }

    public String getNote() {
        return note;
    }

    public void update(Mood mood, int energyLevel, int concentrationLevel, String note, Instant recordedAt) {
        this.mood = mood;
        this.energyLevel = energyLevel;
        this.concentrationLevel = concentrationLevel;
        this.note = note;
        this.recordedAt = recordedAt;
    }
}
