package com.focusmood.user;

import com.focusmood.user.dto.ForgotPasswordRequest;
import com.focusmood.user.dto.ResetPasswordRequest;

/** Recuperación de contraseña (FCM-03). */
public interface PasswordRecoveryService {

    void requestReset(ForgotPasswordRequest request);

    void resetPassword(ResetPasswordRequest request);
}
