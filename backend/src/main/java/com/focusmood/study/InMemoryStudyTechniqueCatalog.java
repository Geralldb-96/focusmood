package com.focusmood.study;

import java.util.List;
import org.springframework.stereotype.Component;

@Component
class InMemoryStudyTechniqueCatalog implements StudyTechniqueCatalog {

    private static final List<StudyTechnique> TECHNIQUES = List.of(
            new StudyTechnique("POMODORO", "Pomodoro",
                    "Bloques de 25 minutos de enfoque con 5 de descanso; tras cuatro bloques, una pausa larga.", 25),
            new StudyTechnique("ACTIVE_RECALL", "Recuerdo activo",
                    "Cierra los apuntes y escribe o explica en voz alta lo que recuerdas; luego verifica y corrige.", 20),
            new StudyTechnique("FEYNMAN", "Técnica Feynman",
                    "Explica el tema con palabras simples como si enseñaras a alguien; detecta y refuerza los vacíos.", 30),
            new StudyTechnique("SPACED_REPETITION", "Repetición espaciada",
                    "Repasa el material en intervalos crecientes (hoy, mañana, en tres días, en una semana).", 15),
            new StudyTechnique("MIND_MAP", "Mapa mental",
                    "Resume el tema en un esquema visual con ideas centrales y ramas conectadas.", 30),
            new StudyTechnique("MICRO_BLOCK", "Bloque corto de enfoque",
                    "Una sola tarea pequeña con un temporizador corto, ideal cuando tienes poco tiempo o energía.", 10));

    @Override
    public List<StudyTechnique> all() {
        return TECHNIQUES;
    }
}
