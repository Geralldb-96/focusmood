package com.focusmood.recommendation.ai;

import static org.assertj.core.api.Assertions.assertThat;

import com.focusmood.daily.Mood;
import com.focusmood.recommendation.RecommendationCategory;
import com.focusmood.recommendation.RecommendationDraft;
import org.junit.jupiter.api.Test;

class ResilientRecommendationGeneratorTest {

    private final RecommendationContext context = new RecommendationContext(Mood.NEUTRAL, 3, 3, 30, "Parcial");
    private final RecommendationValidator validator = new SafetyRecommendationValidator();
    private final RecommendationGenerator fallback = new RuleBasedRecommendationGenerator();

    private static RecommendationDraft good() {
        return new RecommendationDraft(RecommendationCategory.STUDY_TECHNIQUE, "Recuerdo activo", "Recuerdo activo", 20,
                "Cierra los apuntes y escribe lo que recuerdas; luego verifica y corrige.", "gemini-test");
    }

    @Test
    void usesPrimaryWhenItReturnsAValidDraft() {
        var generator = new ResilientRecommendationGenerator(c -> good(), fallback, validator);
        assertThat(generator.generate(context).source()).isEqualTo("gemini-test");
    }

    @Test
    void fallsBackWhenPrimaryIsUnavailable() {
        var generator = new ResilientRecommendationGenerator(c -> {
            throw new AiUnavailableException("caído");
        }, fallback, validator);
        assertThat(generator.generate(context).source()).isEqualTo(RuleBasedRecommendationGenerator.SOURCE);
    }

    @Test
    void fallsBackWhenPrimaryReturnsUnsafeContent() {
        RecommendationGenerator unsafe = c -> new RecommendationDraft(RecommendationCategory.WELLNESS_ACTIVITY,
                "Ayuda", "Pausa", 10, "Debes tomar un medicamento para tu ansiedad ahora mismo.", "gemini-test");
        var generator = new ResilientRecommendationGenerator(unsafe, fallback, validator);
        assertThat(generator.generate(context).source()).isEqualTo(RuleBasedRecommendationGenerator.SOURCE);
    }

    @Test
    void fallsBackOnUnexpectedRuntimeErrors() {
        var generator = new ResilientRecommendationGenerator(c -> {
            throw new IllegalStateException("bug");
        }, fallback, validator);
        assertThat(generator.generate(context).source()).isEqualTo(RuleBasedRecommendationGenerator.SOURCE);
    }
}
