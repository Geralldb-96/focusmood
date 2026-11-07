package com.focusmood.user;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;

/** Token de un solo uso para restablecer la contraseña. Solo se persiste su hash SHA-256. */
@Entity
@Table(name = "token_recuperacion")
public class PasswordResetToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_token")
    private Long id;

    @Column(name = "id_usuario", nullable = false)
    private Long userId;

    @Column(name = "token_hash", nullable = false, unique = true, length = 64)
    private String tokenHash;

    @Column(name = "expira_en", nullable = false)
    private Instant expiresAt;

    @Column(name = "usado", nullable = false)
    private boolean used;

    protected PasswordResetToken() {
    }

    public PasswordResetToken(Long userId, String tokenHash, Instant expiresAt) {
        this.userId = userId;
        this.tokenHash = tokenHash;
        this.expiresAt = expiresAt;
    }

    public Long getUserId() {
        return userId;
    }

    public boolean isUsable(Instant now) {
        return !used && expiresAt.isAfter(now);
    }

    public void markUsed() {
        this.used = true;
    }
}
