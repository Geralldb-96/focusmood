package com.focusmood.recommendation.ai;

import com.focusmood.recommendation.RecommendationCategory;
import com.focusmood.recommendation.RecommendationDraft;
import java.net.http.HttpClient;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.MediaType;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

/**
 * Adaptador de la API REST de Gemini. Solo se encarga de la comunicación y del parseo de la respuesta;
 * la validación de contenido vive en {@link RecommendationValidator} y el respaldo en el decorador resiliente.
 */
@Component
@Qualifier("gemini")
class GeminiRecommendationGenerator implements RecommendationGenerator {

    private static final Logger log = LoggerFactory.getLogger(GeminiRecommendationGenerator.class);
    private static final JsonMapper MAPPER = JsonMapper.builder().build();

    private final GeminiProperties properties;
    private final PromptBuilder promptBuilder;
    private final RestClient client;

    GeminiRecommendationGenerator(GeminiProperties properties, PromptBuilder promptBuilder) {
        this.properties = properties;
        this.promptBuilder = promptBuilder;
        HttpClient httpClient = HttpClient.newBuilder().connectTimeout(properties.timeout()).build();
        JdkClientHttpRequestFactory factory = new JdkClientHttpRequestFactory(httpClient);
        factory.setReadTimeout(properties.timeout());
        this.client = RestClient.builder().baseUrl(properties.baseUrl()).requestFactory(factory).build();
    }

    @Override
    public RecommendationDraft generate(RecommendationContext context) {
        if (!properties.configured()) {
            throw new AiUnavailableException("GEMINI_API_KEY no está configurada.");
        }
        JsonNode response;
        try {
            response = client.post()
                    .uri("/models/{model}:generateContent", properties.model())
                    .header("x-goog-api-key", properties.apiKey())
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(requestBody(context))
                    .retrieve()
                    .body(JsonNode.class);
        } catch (RuntimeException e) {
            // No se registra el cuerpo ni la URL completa: podrían exponer datos sensibles.
            log.warn("Fallo al consultar Gemini: {}", e.getClass().getSimpleName());
            throw new AiUnavailableException("Gemini no respondió correctamente.", e);
        }
        return parse(response);
    }

    private Map<String, Object> requestBody(RecommendationContext context) {
        Map<String, Object> schema = Map.of(
                "type", "OBJECT",
                "properties", Map.of(
                        "category", Map.of("type", "STRING", "enum", List.of("STUDY_TECHNIQUE", "WELLNESS_ACTIVITY")),
                        "title", Map.of("type", "STRING"),
                        "technique", Map.of("type", "STRING"),
                        "durationMinutes", Map.of("type", "INTEGER"),
                        "instructions", Map.of("type", "STRING")),
                "required", List.of("category", "title", "technique", "durationMinutes", "instructions"));
        return Map.of(
                "systemInstruction", Map.of("parts", List.of(Map.of("text", promptBuilder.systemInstruction()))),
                "contents", List.of(Map.of("role", "user",
                        "parts", List.of(Map.of("text", promptBuilder.userPrompt(context))))),
                "generationConfig", Map.of(
                        "temperature", 0.7,
                        "maxOutputTokens", 1024,
                        "responseMimeType", "application/json",
                        "responseSchema", schema));
    }

    private RecommendationDraft parse(JsonNode response) {
        if (response == null) {
            throw new InvalidAiResponseException("Gemini devolvió una respuesta vacía.");
        }
        JsonNode textNode = response.path("candidates").path(0).path("content").path("parts").path(0).path("text");
        if (!textNode.isString() || textNode.asString().isBlank()) {
            throw new InvalidAiResponseException("Gemini no devolvió contenido (posible bloqueo de seguridad).");
        }
        try {
            JsonNode json = MAPPER.readTree(textNode.asString());
            RecommendationCategory category = RecommendationCategory.valueOf(json.path("category").asString(""));
            return new RecommendationDraft(category, json.path("title").asString("").strip(),
                    json.path("technique").asString("").strip(), json.path("durationMinutes").asInt(0),
                    json.path("instructions").asString("").strip(), properties.model());
        } catch (RuntimeException e) {
            throw new InvalidAiResponseException("La respuesta de Gemini no tiene el formato esperado.");
        }
    }
}
