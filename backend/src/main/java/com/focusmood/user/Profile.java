package com.focusmood.user;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Version;

@Entity
@Table(name = "perfil")
public class Profile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_perfil")
    private Long id;

    @Version
    @Column(name = "version", nullable = false)
    private long version;

    @Column(name = "id_usuario", nullable = false, unique = true)
    private Long userId;

    @Column(name = "carrera", length = 120)
    private String career;

    @Column(name = "semestre")
    private Integer semester;

    @Column(name = "preferencias")
    private String preferences;

    @Column(name = "foto_perfil", length = 500)
    private String photoUrl;

    protected Profile() {
    }

    public Profile(Long userId) {
        this.userId = userId;
    }

    public Long getId() {
        return id;
    }

    public Long getUserId() {
        return userId;
    }

    public String getCareer() {
        return career;
    }

    public Integer getSemester() {
        return semester;
    }

    public String getPreferences() {
        return preferences;
    }

    public String getPhotoUrl() {
        return photoUrl;
    }

    public void update(String career, Integer semester, String preferences, String photoUrl) {
        this.career = career;
        this.semester = semester;
        this.preferences = preferences;
        this.photoUrl = photoUrl;
    }
}
