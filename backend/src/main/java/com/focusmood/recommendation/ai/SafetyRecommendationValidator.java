package com.focusmood.recommendation.ai;

import com.focusmood.recommendation.RecommendationDraft;
import java.text.Normalizer;
import java.util.List;
import java.util.Locale;
import org.springframework.stereotype.Component;

@Component
class SafetyRecommendationValidator implements RecommendationValidator {

    private static final int MAX_TITLE = 150;
    private static final int MAX_TECHNIQUE = 100;
    private static final int MAX_INSTRUCTIONS = 2000;
    private static final int MIN_INSTRUCTIONS = 20;

    /** Raíces (sin tildes, en minúscula) de términos clínicos que la IA no debe emitir (RNF-23). */
    private static final List<String> CLINICAL_TERMS = List.of(
            "diagnostic", "medicament", "farmaco", "antidepresiv", "ansiolitic", "psicofarmac",
            "tratamiento", "receta medica", "dosis", "terapia farmacologica", "trastorno", "depresion clinica");

    /** Términos ofensivos básicos (RNF-24). */
    private static final List<String> OFFENSIVE_TERMS = List.of(
            "idiota", "estupid", "imbecil", "inutil", "tonto", "perezoso", "fracasad");

    @Override
    public void validate(RecommendationDraft draft, RecommendationContext context) {
        require(notBlank(draft.title()) && notBlank(draft.technique()), "La recomendación no incluye título o técnica.");
        require(draft.category() != null, "La recomendación no indica su categoría.");
        require(notBlank(draft.instructions()) && draft.instructions().strip().length() >= MIN_INSTRUCTIONS,
                "Las instrucciones están vacías o incompletas.");
        require(draft.title().length() <= MAX_TITLE && draft.technique().length() <= MAX_TECHNIQUE
                && draft.instructions().length() <= MAX_INSTRUCTIONS, "La recomendación excede la longitud permitida.");
        require(draft.durationMinutes() > 0 && draft.durationMinutes() <= context.availableMinutes(),
                "La duración sugerida no es válida para el tiempo disponible.");

        String text = normalize(draft.title() + " " + draft.technique() + " " + draft.instructions());
        require(CLINICAL_TERMS.stream().noneMatch(text::contains),
                "La respuesta contiene contenido clínico fuera del propósito de la aplicación.");
        require(OFFENSIVE_TERMS.stream().noneMatch(text::contains), "La respuesta contiene lenguaje inapropiado.");
    }

    private static boolean notBlank(String value) {
        return value != null && !value.isBlank();
    }

    private static void require(boolean condition, String message) {
        if (!condition) {
            throw new InvalidAiResponseException(message);
        }
    }

    private static String normalize(String text) {
        String decomposed = Normalizer.normalize(text.toLowerCase(Locale.ROOT), Normalizer.Form.NFD);
        return decomposed.replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
    }
}
