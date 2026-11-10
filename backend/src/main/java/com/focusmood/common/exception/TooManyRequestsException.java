package com.focusmood.common.exception;

/** Demasiados intentos: se traduce a HTTP 429. */
public class TooManyRequestsException extends RuntimeException {

    public TooManyRequestsException(String message) {
        super(message);
    }
}
