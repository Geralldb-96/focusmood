package com.focusmood.recommendation;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.time.Instant;

@Entity
@Table(name = "recomendacion")
public class Recommendation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_recomendacion")
    private Long id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_solicitud", nullable = false, unique = true)
    private RecommendationRequest request;

    @Column(name = "titulo", nullable = false, length = 150)
    private String title;

    @Column(name = "tecnica", nullable = false, length = 100)
    private String technique;

    @Column(name = "duracion_minutos", nullable = false)
    private int durationMinutes;

    @Column(name = "contenido", nullable = false)
    private String instructions;

    @Enumerated(EnumType.STRING)
    @Column(name = "categoria", length = 50)
    private RecommendationCategory category;

    @Column(name = "fecha_generacion", nullable = false)
    private Instant generatedAt;

    @Column(name = "modelo_ia", length = 80)
    private String model;

    protected Recommendation() {
    }

    public Recommendation(RecommendationRequest request, RecommendationDraft draft, Instant generatedAt) {
        this.request = request;
        this.title = draft.title();
        this.technique = draft.technique();
        this.durationMinutes = draft.durationMinutes();
        this.instructions = draft.instructions();
        this.category = draft.category();
        this.generatedAt = generatedAt;
        this.model = draft.source();
    }

    public Long getId() {
        return id;
    }

    public RecommendationRequest getRequest() {
        return request;
    }

    public String getTitle() {
        return title;
    }

    public String getTechnique() {
        return technique;
    }

    public int getDurationMinutes() {
        return durationMinutes;
    }

    public String getInstructions() {
        return instructions;
    }

    public RecommendationCategory getCategory() {
        return category;
    }

    public Instant getGeneratedAt() {
        return generatedAt;
    }

    public String getModel() {
        return model;
    }
}
