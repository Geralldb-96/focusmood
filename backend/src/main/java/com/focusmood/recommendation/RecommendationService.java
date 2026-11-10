package com.focusmood.recommendation;

import com.focusmood.recommendation.dto.CreateRecommendationRequest;
import com.focusmood.recommendation.dto.RateRecommendationRequest;
import com.focusmood.recommendation.dto.RecommendationResponse;
import java.util.List;

/** Generación, valoración e historial de recomendaciones (FCM-07, FCM-08, FCM-09). */
public interface RecommendationService {

    RecommendationResponse generate(Long userId, CreateRecommendationRequest request);

    RecommendationResponse rate(Long userId, Long recommendationId, RateRecommendationRequest request);

    RecommendationResponse get(Long userId, Long recommendationId);

    List<RecommendationResponse> history(Long userId);
}
