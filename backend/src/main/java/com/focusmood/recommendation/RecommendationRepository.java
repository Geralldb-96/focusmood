package com.focusmood.recommendation;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface RecommendationRepository extends JpaRepository<Recommendation, Long> {

    @Query("""
            select r from Recommendation r join fetch r.request q join fetch q.dailyLog d
            where r.id = :id and d.userId = :userId
            """)
    Optional<Recommendation> findOwned(@Param("id") Long id, @Param("userId") Long userId);

    @Query("""
            select r from Recommendation r join fetch r.request q join fetch q.dailyLog d
            where d.userId = :userId
            order by r.generatedAt desc
            """)
    List<Recommendation> findHistory(@Param("userId") Long userId);

    @Query("""
            select count(r) from Recommendation r join r.request q join q.dailyLog d
            where d.userId = :userId and r.generatedAt >= :from and r.generatedAt < :to
            """)
    long countGenerated(@Param("userId") Long userId, @Param("from") Instant from, @Param("to") Instant to);
}
