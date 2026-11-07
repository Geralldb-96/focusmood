package com.focusmood.recommendation;

/**
 * Recomendación propuesta por un generador, aún no validada ni persistida.
 *
 * @param source identificador de quién la generó (p. ej. modelo de IA o "reglas-locales").
 */
public record RecommendationDraft(
        RecommendationCategory category, String title, String technique, int durationMinutes,
        String instructions, String source) {

    public RecommendationDraft withSource(String newSource) {
        return new RecommendationDraft(category, title, technique, durationMinutes, instructions, newSource);
    }
}
