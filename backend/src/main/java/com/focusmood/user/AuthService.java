package com.focusmood.user;

import com.focusmood.security.ClientInfo;
import com.focusmood.user.dto.AuthResponse;
import com.focusmood.user.dto.RefreshRequest;
import com.focusmood.user.dto.LoginRequest;
import com.focusmood.user.dto.RegisterRequest;

/** Registro e inicio de sesión (FCM-01, FCM-02). */
public interface AuthService {

    AuthResponse register(RegisterRequest request, ClientInfo client);

    AuthResponse login(LoginRequest request, ClientInfo client);

    /** Canjea un refresh token por un access token y un refresh token nuevos (rotación). */
    AuthResponse refresh(RefreshRequest request);
}
