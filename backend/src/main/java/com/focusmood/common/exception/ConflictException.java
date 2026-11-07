package com.focusmood.common.exception;

/** La operación duplicaría información o choca con el estado actual (RNF-14). */
public class ConflictException extends RuntimeException {

    public ConflictException(String message) {
        super(message);
    }
}
