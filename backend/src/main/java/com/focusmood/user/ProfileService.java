package com.focusmood.user;

import com.focusmood.user.dto.ProfileResponse;
import com.focusmood.user.dto.UpdateProfileRequest;

/** Consulta y edición del perfil (FCM-04). */
public interface ProfileService {

    ProfileResponse get(Long userId);

    ProfileResponse update(Long userId, UpdateProfileRequest request);
}
