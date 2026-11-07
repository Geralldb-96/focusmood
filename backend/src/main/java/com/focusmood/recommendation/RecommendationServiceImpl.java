package com.focusmood.recommendation;

import com.focusmood.common.exception.ResourceNotFoundException;
import com.focusmood.daily.DailyLog;
import com.focusmood.daily.DailyLogRepository;
import com.focusmood.recommendation.ai.RecommendationContext;
import com.focusmood.recommendation.ai.RecommendationGenerator;
import com.focusmood.recommendation.dto.CreateRecommendationRequest;
import com.focusmood.recommendation.dto.RateRecommendationRequest;
import com.focusmood.recommendation.dto.RecommendationResponse;
import java.time.Clock;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

/**
 * Orquesta el caso de uso. La llamada a la IA se hace fuera de cualquier transacción para no mantener
 * una conexión a la base de datos abierta mientras se espera al proveedor externo (hasta 10 s, RNF-04).
 */
@Service
class RecommendationServiceImpl implements RecommendationService {

    private final DailyLogRepository dailyLogs;
    private final RecommendationRequestRepository requests;
    private final RecommendationRepository recommendations;
    private final RatingRepository ratings;
    private final RecommendationGenerator generator;
    private final TransactionTemplate tx;
    private final Clock clock;

    RecommendationServiceImpl(DailyLogRepository dailyLogs, RecommendationRequestRepository requests,
                              RecommendationRepository recommendations, RatingRepository ratings,
                              RecommendationGenerator generator, TransactionTemplate tx, Clock clock) {
        this.dailyLogs = dailyLogs;
        this.requests = requests;
        this.recommendations = recommendations;
        this.ratings = ratings;
        this.generator = generator;
        this.tx = tx;
        this.clock = clock;
    }

    @Override
    public RecommendationResponse generate(Long userId, CreateRecommendationRequest request) {
        DailyLog log = tx.execute(s -> dailyLogs.findByIdAndUserId(request.dailyLogId(), userId)
                .orElseThrow(() -> new ResourceNotFoundException("Registro diario no encontrado.")));

        String activity = request.academicActivity().trim();
        RecommendationDraft draft = generator.generate(new RecommendationContext(log.getMood(),
                log.getEnergyLevel(), log.getConcentrationLevel(), request.availableMinutes(), activity));

        return tx.execute(s -> {
            DailyLog managed = dailyLogs.getReferenceById(log.getId());
            RecommendationRequest saved = requests.save(
                    new RecommendationRequest(managed, clock.instant(), request.availableMinutes(), activity));
            Recommendation recommendation = recommendations.save(new Recommendation(saved, draft, clock.instant()));
            return RecommendationResponse.from(recommendation, null);
        });
    }

    @Override
    public RecommendationResponse rate(Long userId, Long recommendationId, RateRecommendationRequest request) {
        return tx.execute(s -> {
            Recommendation recommendation = findOwned(userId, recommendationId);
            String comment = request.comment() == null || request.comment().isBlank() ? null : request.comment().trim();
            Rating rating = ratings.findByRecommendationId(recommendationId).orElse(null);
            if (rating == null) {
                rating = ratings.save(new Rating(recommendation, request.score(), comment, clock.instant()));
            } else {
                rating.revise(request.score(), comment, clock.instant());
            }
            return RecommendationResponse.from(recommendation, rating);
        });
    }

    @Override
    public RecommendationResponse get(Long userId, Long recommendationId) {
        return tx.execute(s -> {
            Recommendation recommendation = findOwned(userId, recommendationId);
            return RecommendationResponse.from(recommendation,
                    ratings.findByRecommendationId(recommendationId).orElse(null));
        });
    }

    @Override
    public List<RecommendationResponse> history(Long userId) {
        return tx.execute(s -> {
            List<Recommendation> found = recommendations.findHistory(userId);
            if (found.isEmpty()) {
                return List.<RecommendationResponse>of();
            }
            Map<Long, Rating> byRecommendation = ratings
                    .findByRecommendationIds(found.stream().map(Recommendation::getId).toList()).stream()
                    .collect(Collectors.toMap(r -> r.getRecommendation().getId(), Function.identity()));
            return found.stream()
                    .map(r -> RecommendationResponse.from(r, byRecommendation.get(r.getId())))
                    .toList();
        });
    }

    private Recommendation findOwned(Long userId, Long id) {
        return recommendations.findOwned(id, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Recomendación no encontrada."));
    }
}
