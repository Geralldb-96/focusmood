package com.focusmood.security;

import jakarta.servlet.http.HttpServletRequest;

/** Datos del cliente que abre o renueva una sesión (para listarla y auditarla). */
public record ClientInfo(String ip, String userAgent) {

    public static ClientInfo from(HttpServletRequest request) {
        String ua = request.getHeader("User-Agent");
        if (ua != null && ua.length() > 255) {
            ua = ua.substring(0, 255);
        }
        String ip = request.getRemoteAddr();
        if (ip != null && ip.length() > 45) {
            ip = ip.substring(0, 45);
        }
        return new ClientInfo(ip, ua);
    }
}
