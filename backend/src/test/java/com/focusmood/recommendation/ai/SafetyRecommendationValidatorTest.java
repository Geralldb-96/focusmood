package com.focusmood.recommendation.ai;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.focusmood.daily.Mood;
import com.focusmood.recommendation.RecommendationCategory;
import com.focusmood.recommendation.RecommendationDraft;
import org.junit.jupiter.api.Test;

class SafetyRecommendationValidatorTest {

    private final SafetyRecommendationValidator validator = new SafetyRecommendationValidator();
    private final RecommendationContext context = new RecommendationContext(Mood.NEUTRAL, 3, 3, 30, "Parcial de cálculo");

    private RecommendationDraft draft(String title, String technique, int minutes, String instructions) {
        return new RecommendationDraft(RecommendationCategory.STUDY_TECHNIQUE, title, technique, minutes,
                instructions, "test");
    }

    @Test
    void acceptsAValidDraft() {
        assertThatCode(() -> validator.validate(
                draft("Pomodoro clásico", "Pomodoro", 25, "Trabaja 25 minutos sin distracciones y descansa 5."), context))
                .doesNotThrowAnyException();
    }

    @Test
    void rejectsEmptyOrTooShortInstructions() {
        assertThatThrownBy(() -> validator.validate(draft("Título", "Técnica", 20, "  "), context))
                .isInstanceOf(InvalidAiResponseException.class);
        assertThatThrownBy(() -> validator.validate(draft("Título", "Técnica", 20, "Corto"), context))
                .isInstanceOf(InvalidAiResponseException.class);
    }

    @Test
    void rejectsDurationAboveAvailableTime() {
        assertThatThrownBy(() -> validator.validate(
                draft("Título", "Técnica", 45, "Estudia durante bastante tiempo sin parar nunca."), context))
                .isInstanceOf(InvalidAiResponseException.class);
    }

    @Test
    void rejectsClinicalContentEvenWithAccents() {
        assertThatThrownBy(() -> validator.validate(
                draft("Ayuda", "Pausa", 10, "Parece un trastorno; consulta el DIAGNÓSTICO y toma un medicamento."), context))
                .isInstanceOf(InvalidAiResponseException.class);
    }

    @Test
    void rejectsOffensiveLanguage() {
        assertThatThrownBy(() -> validator.validate(
                draft("Ayuda", "Pausa", 10, "No seas perezoso y ponte a estudiar de una vez por todas."), context))
                .isInstanceOf(InvalidAiResponseException.class);
    }
}
