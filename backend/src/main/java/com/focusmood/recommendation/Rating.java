package com.focusmood.recommendation;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.time.Instant;

/** Valoración de una recomendación (tabla calificacion): máximo una por recomendación. */
@Entity
@Table(name = "calificacion")
public class Rating {

    /** Puntuación mínima considerada "me sirvió". */
    public static final int HELPFUL_THRESHOLD = 4;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_calificacion")
    private Long id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_recomendacion", nullable = false, unique = true)
    private Recommendation recommendation;

    @Column(name = "puntuacion", nullable = false)
    private int score;

    @Column(name = "comentario", length = 500)
    private String comment;

    @Column(name = "fecha_calificacion", nullable = false)
    private Instant ratedAt;

    protected Rating() {
    }

    public Rating(Recommendation recommendation, int score, String comment, Instant ratedAt) {
        this.recommendation = recommendation;
        this.score = score;
        this.comment = comment;
        this.ratedAt = ratedAt;
    }

    public Recommendation getRecommendation() {
        return recommendation;
    }

    public int getScore() {
        return score;
    }

    public String getComment() {
        return comment;
    }

    public Instant getRatedAt() {
        return ratedAt;
    }

    public boolean isHelpful() {
        return score >= HELPFUL_THRESHOLD;
    }

    public void revise(int score, String comment, Instant ratedAt) {
        this.score = score;
        this.comment = comment;
        this.ratedAt = ratedAt;
    }
}
