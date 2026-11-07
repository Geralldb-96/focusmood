package com.focusmood.recommendation.ai;

import com.focusmood.daily.Mood;
import com.focusmood.recommendation.RecommendationCategory;
import com.focusmood.recommendation.RecommendationDraft;
import java.util.Set;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

/**
 * Recomendación general segura basada en reglas (RF-30). Se usa cuando la IA no está disponible o su respuesta
 * no pasa la validación. Siempre cumple el tiempo disponible indicado por el estudiante.
 */
@Component
@Qualifier("ruleBased")
class RuleBasedRecommendationGenerator implements RecommendationGenerator {

    static final String SOURCE = "reglas-locales";
    private static final Set<Mood> LOW_MOODS = Set.of(Mood.ESTRESADO, Mood.ANSIOSO, Mood.TRISTE, Mood.CANSADO);

    @Override
    public RecommendationDraft generate(RecommendationContext c) {
        int minutes = c.availableMinutes();
        boolean lowEnergy = c.energyLevel() <= 2;
        boolean lowMood = LOW_MOODS.contains(c.mood());
        boolean lowFocus = c.concentrationLevel() <= 2;

        if (minutes < 10 || (lowMood && lowEnergy)) {
            int duration = Math.min(3, minutes);
            return new RecommendationDraft(RecommendationCategory.WELLNESS_ACTIVITY, "Respira y reinicia",
                    "Respiración cuadrada", duration,
                    "Siéntate con la espalda recta. Inhala 4 segundos, sostén el aire 4, exhala 4 y descansa 4. "
                            + "Repite durante " + duration + " minutos. Luego retoma «" + c.academicActivity()
                            + "» con una meta pequeña.", SOURCE);
        }
        if (lowFocus) {
            int duration = Math.min(15, minutes);
            return new RecommendationDraft(RecommendationCategory.STUDY_TECHNIQUE, "Bloque corto de enfoque",
                    "Bloque corto de enfoque", duration,
                    "Silencia el celular y elige una sola tarea pequeña de «" + c.academicActivity() + "». "
                            + "Trabaja " + duration + " minutos sin interrupciones y anota al final qué lograste.",
                    SOURCE);
        }
        if (minutes >= 55 && c.energyLevel() >= 4 && c.concentrationLevel() >= 4) {
            return new RecommendationDraft(RecommendationCategory.STUDY_TECHNIQUE, "Estudio profundo con Pomodoro",
                    "Pomodoro", 55,
                    "Haz dos bloques de 25 minutos de enfoque sobre «" + c.academicActivity() + "» con 5 minutos "
                            + "de descanso entre ellos. Al terminar, explica en voz alta lo aprendido sin mirar tus apuntes.",
                    SOURCE);
        }
        int duration = Math.min(25, minutes);
        return new RecommendationDraft(RecommendationCategory.STUDY_TECHNIQUE, "Pomodoro clásico", "Pomodoro", duration,
                "Trabaja " + duration + " minutos en «" + c.academicActivity() + "» sin distracciones. "
                        + "Cuando suene el temporizador, descansa 5 minutos: estírate y toma agua.", SOURCE);
    }
}
