package com.focusmood.study;

import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/study-techniques")
class StudyTechniqueController {

    private final StudyTechniqueCatalog catalog;

    StudyTechniqueController(StudyTechniqueCatalog catalog) {
        this.catalog = catalog;
    }

    @GetMapping
    List<StudyTechnique> list() {
        return catalog.all();
    }
}
