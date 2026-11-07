package com.focusmood.user;

import com.focusmood.common.exception.ResourceNotFoundException;
import com.focusmood.user.dto.ProfileResponse;
import com.focusmood.user.dto.UpdateProfileRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
class ProfileServiceImpl implements ProfileService {

    private final UserRepository users;
    private final ProfileRepository profiles;

    ProfileServiceImpl(UserRepository users, ProfileRepository profiles) {
        this.users = users;
        this.profiles = profiles;
    }

    @Override
    @Transactional(readOnly = true)
    public ProfileResponse get(Long userId) {
        return ProfileResponse.of(loadUser(userId), loadProfile(userId));
    }

    @Override
    @Transactional
    public ProfileResponse update(Long userId, UpdateProfileRequest request) {
        User user = loadUser(userId);
        Profile profile = loadProfile(userId);
        user.rename(request.name().trim());
        profile.update(blankToNull(request.career()), request.semester(), blankToNull(request.preferences()),
                blankToNull(request.photoUrl()));
        return ProfileResponse.of(user, profile);
    }

    private User loadUser(Long userId) {
        return users.findById(userId).orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado."));
    }

    private Profile loadProfile(Long userId) {
        return profiles.findByUserId(userId).orElseThrow(() -> new ResourceNotFoundException("Perfil no encontrado."));
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
