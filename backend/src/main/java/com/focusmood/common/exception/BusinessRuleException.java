package com.focusmood.common.exception;

/** Los datos son sintácticamente válidos pero incumplen una regla de negocio. */
public class BusinessRuleException extends RuntimeException {

    public BusinessRuleException(String message) {
        super(message);
    }
}
