package com.focusmood.recommendation.ai;

import java.time.Duration;
import org.springframework.boot.context.properties.ConfigurationProperties;

/** La clave se lee de la variable de entorno GEMINI_API_KEY; nunca va en el código ni en la app móvil (RNF-08). */
@ConfigurationProperties(prefix = "focusmood.ai.gemini")
public record GeminiProperties(String apiKey, String model, String baseUrl, Duration timeout) {

    public GeminiProperties {
        model = model == null || model.isBlank() ? "gemini-2.5-flash" : model;
        baseUrl = baseUrl == null || baseUrl.isBlank() ? "https://generativelanguage.googleapis.com/v1beta" : baseUrl;
        timeout = timeout == null ? Duration.ofSeconds(10) : timeout;
    }

    public boolean configured() {
        return apiKey != null && !apiKey.isBlank();
    }
}
