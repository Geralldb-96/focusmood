package com.focusmood.wellness;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface WellnessActivityRepository extends JpaRepository<WellnessActivity, Long> {

    List<WellnessActivity> findByActiveTrueOrderByNameAsc();

    List<WellnessActivity> findByActiveTrueAndCategoryOrderByNameAsc(WellnessCategory category);

    Optional<WellnessActivity> findByIdAndActiveTrue(Long id);
}
