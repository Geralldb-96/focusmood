package com.focusmood.recommendation.dto;

import com.focusmood.daily.Mood;
import com.focusmood.recommendation.Rating;
import com.focusmood.recommendation.Recommendation;
import com.focusmood.recommendation.RecommendationCategory;
import com.focusmood.recommendation.RecommendationRequest;
import java.time.Instant;
import java.time.LocalDate;

public record RecommendationResponse(
        Long id, RecommendationCategory category, String title, String technique, int durationMinutes,
        String instructions, String source, Instant generatedAt, Context context, RatingView rating, String disclaimer) {

    public static final String DISCLAIMER =
            "Las recomendaciones son orientativas y educativas; no reemplazan la orientación médica o psicológica.";

    public record Context(LocalDate date, Mood mood, int energyLevel, int concentrationLevel, int availableMinutes,
                          String academicActivity) {
    }

    public record RatingView(int score, boolean helpful, String comment, Instant ratedAt) {

        static RatingView from(Rating r) {
            return new RatingView(r.getScore(), r.isHelpful(), r.getComment(), r.getRatedAt());
        }
    }

    public static RecommendationResponse from(Recommendation r, Rating rating) {
        RecommendationRequest q = r.getRequest();
        Context context = new Context(q.getDailyLog().getDate(), q.getDailyLog().getMood(),
                q.getDailyLog().getEnergyLevel(), q.getDailyLog().getConcentrationLevel(), q.getAvailableMinutes(),
                q.getAcademicActivity());
        return new RecommendationResponse(r.getId(), r.getCategory(), r.getTitle(), r.getTechnique(),
                r.getDurationMinutes(), r.getInstructions(), r.getModel(), r.getGeneratedAt(), context,
                rating == null ? null : RatingView.from(rating), DISCLAIMER);
    }
}
