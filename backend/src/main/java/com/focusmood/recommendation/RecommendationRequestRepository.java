package com.focusmood.recommendation;

import org.springframework.data.jpa.repository.JpaRepository;

public interface RecommendationRequestRepository extends JpaRepository<RecommendationRequest, Long> {
}
