package com.focusmood.recommendation;

import com.focusmood.common.web.CurrentUserId;
import com.focusmood.recommendation.dto.CreateRecommendationRequest;
import com.focusmood.recommendation.dto.RateRecommendationRequest;
import com.focusmood.recommendation.dto.RecommendationResponse;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/recommendations")
class RecommendationController {

    private final RecommendationService service;

    RecommendationController(RecommendationService service) {
        this.service = service;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    RecommendationResponse generate(@CurrentUserId Long userId, @Valid @RequestBody CreateRecommendationRequest request) {
        return service.generate(userId, request);
    }

    @GetMapping
    List<RecommendationResponse> history(@CurrentUserId Long userId) {
        return service.history(userId);
    }

    @GetMapping("/{id}")
    RecommendationResponse get(@CurrentUserId Long userId, @PathVariable Long id) {
        return service.get(userId, id);
    }

    /** Idempotente: repetir la valoración actualiza la existente (RNF-14). */
    @PutMapping("/{id}/rating")
    RecommendationResponse rate(@CurrentUserId Long userId, @PathVariable Long id,
                                @Valid @RequestBody RateRecommendationRequest request) {
        return service.rate(userId, id, request);
    }
}
