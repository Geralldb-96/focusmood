package com.focusmood.user.dto;

import com.focusmood.user.Profile;
import com.focusmood.user.User;

public record ProfileResponse(
        Long userId, String name, String email, String career, Integer semester, String preferences, String photoUrl) {

    public static ProfileResponse of(User user, Profile profile) {
        return new ProfileResponse(user.getId(), user.getName(), user.getEmail(), profile.getCareer(),
                profile.getSemester(), profile.getPreferences(), profile.getPhotoUrl());
    }
}
