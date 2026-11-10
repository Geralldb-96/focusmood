package com.focusmood.user;

import com.focusmood.common.web.CurrentUserId;
import com.focusmood.user.dto.ProfileResponse;
import com.focusmood.user.dto.UpdateProfileRequest;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/profile")
class ProfileController {

    private final ProfileService profileService;

    ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }

    @GetMapping
    ProfileResponse get(@CurrentUserId Long userId) {
        return profileService.get(userId);
    }

    @PutMapping
    ProfileResponse update(@CurrentUserId Long userId, @Valid @RequestBody UpdateProfileRequest request) {
        return profileService.update(userId, request);
    }
}
