package com.focusmood.recommendation;

import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface RatingRepository extends JpaRepository<Rating, Long> {

    @Query("select c from Rating c where c.recommendation.id = :recommendationId")
    Optional<Rating> findByRecommendationId(@Param("recommendationId") Long recommendationId);

    @Query("select c from Rating c where c.recommendation.id in :ids")
    List<Rating> findByRecommendationIds(@Param("ids") Collection<Long> ids);

    @Query("""
            select c from Rating c join c.recommendation r join r.request q join q.dailyLog d
            where d.userId = :userId and c.ratedAt >= :from and c.ratedAt < :to
            """)
    List<Rating> findRatedBetween(@Param("userId") Long userId, @Param("from") Instant from, @Param("to") Instant to);
}
