package com.focusmood.recommendation.ai;

import com.focusmood.daily.Mood;

/**
 * Datos mínimos enviados a la IA (RNF-10): sin nombre, correo ni identificadores del usuario.
 */
public record RecommendationContext(
        Mood mood, int energyLevel, int concentrationLevel, int availableMinutes, String academicActivity) {
}
