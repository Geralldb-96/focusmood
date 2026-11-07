package com.focusmood.recommendation.ai;

import com.focusmood.recommendation.RecommendationDraft;

/**
 * Estrategia de generación de recomendaciones. Implementaciones intercambiables (Gemini, reglas locales...)
 * permiten reemplazar la IA sin tocar el servicio de recomendaciones (sección 4.2, justificación).
 */
public interface RecommendationGenerator {

    /** @throws AiUnavailableException si el proveedor no puede responder. */
    RecommendationDraft generate(RecommendationContext context);
}
