package com.focusmood.common.exception;

/** El recurso no existe o no pertenece al usuario autenticado (RNF-07: no se revela cuál de los dos). */
public class ResourceNotFoundException extends RuntimeException {

    public ResourceNotFoundException(String message) {
        super(message);
    }
}
