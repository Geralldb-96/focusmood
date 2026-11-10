package com.focusmood.security;

import jakarta.persistence.LockModeType;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

interface UserSessionRepository extends JpaRepository<UserSession, String> {

    /** Bloqueo de escritura: evita que dos refresh simultáneos con el mismo token tengan éxito. */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select s from UserSession s where s.id = :id")
    Optional<UserSession> findForUpdate(@Param("id") String id);

    @Query("""
            select count(s) > 0 from UserSession s, User u
            where s.id = :id and s.userId = u.id and u.active = true
              and s.revoked = false and s.expiresAt > :now""")
    boolean isActive(@Param("id") String id, @Param("now") Instant now);

    List<UserSession> findByUserIdAndRevokedFalseAndExpiresAtAfterOrderByLastUsedAtDesc(Long userId, Instant now);

    Optional<UserSession> findByIdAndUserId(String id, Long userId);

    @Modifying
    @Query("update UserSession s set s.revoked = true where s.userId = :userId and s.revoked = false")
    int revokeAll(@Param("userId") Long userId);

    @Modifying
    @Query("delete from UserSession s where s.expiresAt < :limit or (s.revoked = true and s.lastUsedAt < :limit)")
    int purge(@Param("limit") Instant limit);
}
