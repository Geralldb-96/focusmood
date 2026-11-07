package com.focusmood.recommendation.ai;

/** La respuesta de la IA está vacía, incompleta, es inapropiada o se sale del propósito de la app. */
public class InvalidAiResponseException extends RuntimeException {

    public InvalidAiResponseException(String message) {
        super(message);
    }
}
