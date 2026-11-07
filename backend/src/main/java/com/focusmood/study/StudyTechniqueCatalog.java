package com.focusmood.study;

import java.util.List;

/** Fuente de técnicas de estudio. Agregar técnicas no exige cambiar a los consumidores (RNF-20). */
public interface StudyTechniqueCatalog {

    List<StudyTechnique> all();
}
