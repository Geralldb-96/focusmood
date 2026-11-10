package com.focusmood.study;

/** Técnica de estudio disponible en el catálogo (sección 5.6.1). */
public record StudyTechnique(String code, String name, String description, int suggestedMinutes) {
}
