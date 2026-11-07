package com.focusmood.recommendation.ai;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;

import com.focusmood.daily.Mood;
import com.focusmood.recommendation.RecommendationCategory;
import com.focusmood.recommendation.RecommendationDraft;
import org.junit.jupiter.api.Test;

class RuleBasedRecommendationGeneratorTest {

    private final RuleBasedRecommendationGenerator generator = new RuleBasedRecommendationGenerator();
    private final SafetyRecommendationValidator validator = new SafetyRecommendationValidator();

    @Test
    void suggestsBreathingWhenMoodAndEnergyAreLow() {
        RecommendationDraft d = generator.generate(new RecommendationContext(Mood.ESTRESADO, 1, 3, 30, "Informe"));
        assertThat(d.category()).isEqualTo(RecommendationCategory.WELLNESS_ACTIVITY);
        assertThat(d.durationMinutes()).isLessThanOrEqualTo(30);
    }

    @Test
    void suggestsShortBlockWhenFocusIsLow() {
        RecommendationDraft d = generator.generate(new RecommendationContext(Mood.NEUTRAL, 3, 1, 30, "Lectura"));
        assertThat(d.technique()).isEqualTo("Bloque corto de enfoque");
        assertThat(d.durationMinutes()).isEqualTo(15);
    }

    @Test
    void suggestsDeepStudyWhenEverythingIsHigh() {
        RecommendationDraft d = generator.generate(new RecommendationContext(Mood.MOTIVADO, 5, 5, 60, "Proyecto"));
        assertThat(d.durationMinutes()).isEqualTo(55);
    }

    @Test
    void neverExceedsAvailableTimeAndAlwaysPassesValidation() {
        for (Mood mood : Mood.values()) {
            for (int energy = 1; energy <= 5; energy++) {
                for (int focus = 1; focus <= 5; focus++) {
                    for (int minutes : new int[]{1, 5, 9, 10, 20, 44, 54, 55, 90}) {
                        RecommendationContext c = new RecommendationContext(mood, energy, focus, minutes, "Examen");
                        RecommendationDraft d = generator.generate(c);
                        assertThatCode(() -> validator.validate(d, c)).doesNotThrowAnyException();
                    }
                }
            }
        }
    }
}
