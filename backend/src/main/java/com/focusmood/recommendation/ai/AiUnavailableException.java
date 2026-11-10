package com.focusmood.recommendation.ai;

/** El proveedor de IA no está disponible, no está configurado o devolvió un error. */
public class AiUnavailableException extends RuntimeException {

    public AiUnavailableException(String message) {
        super(message);
    }

    public AiUnavailableException(String message, Throwable cause) {
        super(message, cause);
    }
}
