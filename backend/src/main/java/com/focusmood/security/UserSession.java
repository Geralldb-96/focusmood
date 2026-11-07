package com.focusmood.security;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;

/** Sesión revocable en servidor. Solo se guarda el hash del refresh token vigente y del anterior. */
@Entity
@Table(name = "sesion_usuario")
class UserSession {

    @Id
    @Column(name = "id_sesion_usuario", length = 36)
    private String id;

    @Column(name = "id_usuario", nullable = false)
    private Long userId;

    @Column(name = "refresh_hash", nullable = false, length = 64)
    private String refreshHash;

    @Column(name = "refresh_hash_anterior", length = 64)
    private String previousRefreshHash;

    @Column(name = "creada_en", nullable = false)
    private Instant createdAt;

    @Column(name = "ultimo_uso", nullable = false)
    private Instant lastUsedAt;

    @Column(name = "expira_en", nullable = false)
    private Instant expiresAt;

    @Column(name = "revocada", nullable = false)
    private boolean revoked;

    @Column(name = "dispositivo", length = 255)
    private String device;

    @Column(name = "ip", length = 45)
    private String ip;

    protected UserSession() {
    }

    UserSession(String id, Long userId, String refreshHash, Instant now, Instant expiresAt, String device, String ip) {
        this.id = id;
        this.userId = userId;
        this.refreshHash = refreshHash;
        this.createdAt = now;
        this.lastUsedAt = now;
        this.expiresAt = expiresAt;
        this.device = device;
        this.ip = ip;
    }

    String getId() { return id; }
    Long getUserId() { return userId; }
    String getRefreshHash() { return refreshHash; }
    String getPreviousRefreshHash() { return previousRefreshHash; }
    Instant getCreatedAt() { return createdAt; }
    Instant getLastUsedAt() { return lastUsedAt; }
    Instant getExpiresAt() { return expiresAt; }
    boolean isRevoked() { return revoked; }
    String getDevice() { return device; }
    String getIp() { return ip; }

    boolean isActive(Instant now) {
        return !revoked && expiresAt.isAfter(now);
    }

    void revoke() {
        this.revoked = true;
    }

    void rotate(String newHash, Instant now, Instant newExpiry) {
        this.previousRefreshHash = this.refreshHash;
        this.refreshHash = newHash;
        this.lastUsedAt = now;
        this.expiresAt = newExpiry;
    }
}
