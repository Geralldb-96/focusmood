package com.focusmood.recommendation;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
class RecommendationStatsProvider implements RecommendationStats {

    private final RecommendationRepository recommendations;
    private final RatingRepository ratings;
    private final Clock clock;

    RecommendationStatsProvider(RecommendationRepository recommendations, RatingRepository ratings, Clock clock) {
        this.recommendations = recommendations;
        this.ratings = ratings;
        this.clock = clock;
    }

    @Override
    @Transactional(readOnly = true)
    public RecommendationSummary summary(Long userId, LocalDate from, LocalDate to) {
        Instant lower = from.atStartOfDay(clock.getZone()).toInstant();
        Instant upper = to.plusDays(1).atStartOfDay(clock.getZone()).toInstant();
        int generated = (int) recommendations.countGenerated(userId, lower, upper);
        List<Rating> rated = ratings.findRatedBetween(userId, lower, upper);
        int helpful = (int) rated.stream().filter(Rating::isHelpful).count();
        return new RecommendationSummary(generated, rated.size(), helpful);
    }
}
