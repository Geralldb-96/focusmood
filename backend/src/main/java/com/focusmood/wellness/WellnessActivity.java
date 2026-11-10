package com.focusmood.wellness;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/** Actividad del catálogo (solo lectura desde la API). */
@Entity
@Table(name = "actividad_bienestar")
public class WellnessActivity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_actividad")
    private Long id;

    @Column(name = "nombre", nullable = false, length = 120)
    private String name;

    @Column(name = "descripcion", nullable = false)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "categoria", nullable = false, length = 50)
    private WellnessCategory category;

    @Column(name = "duracion_estimada", nullable = false)
    private int estimatedMinutes;

    @Column(name = "activa", nullable = false)
    private boolean active;

    protected WellnessActivity() {
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public WellnessCategory getCategory() {
        return category;
    }

    public int getEstimatedMinutes() {
        return estimatedMinutes;
    }

    public boolean isActive() {
        return active;
    }
}
