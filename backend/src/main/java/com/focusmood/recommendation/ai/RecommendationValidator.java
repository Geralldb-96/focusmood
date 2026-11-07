package com.focusmood.recommendation.ai;

import com.focusmood.recommendation.RecommendationDraft;

/** Control de calidad y seguridad de las respuestas generadas (RNF-22, RNF-23, RNF-24). */
public interface RecommendationValidator {

    /** @throws InvalidAiResponseException si el borrador no es aceptable. */
    void validate(RecommendationDraft draft, RecommendationContext context);
}
