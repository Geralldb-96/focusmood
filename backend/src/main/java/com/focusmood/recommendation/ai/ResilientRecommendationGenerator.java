package com.focusmood.recommendation.ai;

import com.focusmood.recommendation.RecommendationDraft;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Component;

/**
 * Decorador: intenta el generador principal, valida su resultado y, ante cualquier fallo o respuesta
 * inadecuada, responde con el generador de respaldo (RF-30, RNF-13, RNF-24).
 * Es el único {@link RecommendationGenerator} que ve el servicio de recomendaciones.
 */
@Component
@Primary
class ResilientRecommendationGenerator implements RecommendationGenerator {

    private static final Logger log = LoggerFactory.getLogger(ResilientRecommendationGenerator.class);

    private final RecommendationGenerator primary;
    private final RecommendationGenerator fallback;
    private final RecommendationValidator validator;

    ResilientRecommendationGenerator(@Qualifier("gemini") RecommendationGenerator primary,
                                     @Qualifier("ruleBased") RecommendationGenerator fallback,
                                     RecommendationValidator validator) {
        this.primary = primary;
        this.fallback = fallback;
        this.validator = validator;
    }

    @Override
    public RecommendationDraft generate(RecommendationContext context) {
        try {
            RecommendationDraft draft = primary.generate(context);
            validator.validate(draft, context);
            return draft;
        } catch (AiUnavailableException | InvalidAiResponseException e) {
            log.warn("Se usa la recomendación de respaldo: {}", e.getMessage());
        } catch (RuntimeException e) {
            log.error("Error inesperado del generador principal; se usa el respaldo", e);
        }
        RecommendationDraft draft = fallback.generate(context);
        validator.validate(draft, context);
        return draft;
    }
}
