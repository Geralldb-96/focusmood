package com.focusmood.user;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Version;
import java.time.Instant;

@Entity
@Table(name = "usuario")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_usuario")
    private Long id;

    @Version
    @Column(name = "version", nullable = false)
    private long version;

    @Column(name = "nombre", nullable = false, length = 120)
    private String name;

    @Column(name = "correo", nullable = false, unique = true, length = 150)
    private String email;

    @Column(name = "contrasena_hash", nullable = false)
    private String passwordHash;

    @Column(name = "fecha_registro", nullable = false)
    private Instant registeredAt;

    @Column(name = "activo", nullable = false)
    private boolean active = true;

    protected User() {
    }

    public User(String name, String email, String passwordHash, Instant registeredAt) {
        this.name = name;
        this.email = email;
        this.passwordHash = passwordHash;
        this.registeredAt = registeredAt;
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getEmail() {
        return email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public Instant getRegisteredAt() {
        return registeredAt;
    }

    public boolean isActive() {
        return active;
    }

    public void rename(String name) {
        this.name = name;
    }

    public void changePasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }
}
