package com.focusmood.daily;

/** Estados de ánimo disponibles, con una valencia 1-5 usada para promedios y gráficas. */
public enum Mood {
    ESTRESADO("estresado", 1),
    ANSIOSO("ansioso", 1),
    TRISTE("triste", 2),
    CANSADO("cansado", 2),
    NEUTRAL("neutral", 3),
    CALMADO("calmado", 4),
    MOTIVADO("motivado", 5),
    FELIZ("feliz", 5);

    private final String label;
    private final int score;

    Mood(String label, int score) {
        this.label = label;
        this.score = score;
    }

    public String label() {
        return label;
    }

    public int score() {
        return score;
    }
}
