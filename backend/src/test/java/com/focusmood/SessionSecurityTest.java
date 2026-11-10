package com.focusmood;

import static org.hamcrest.Matchers.hasItem;
import static org.hamcrest.Matchers.not;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.jayway.jsonpath.JsonPath;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

/** Tokens y sesiones: rotación, reutilización, revocación, límite de intentos y cabeceras. */
@SpringBootTest
@AutoConfigureMockMvc
class SessionSecurityTest {

    private static final String PASSWORD = "Clave1234";

    @Autowired
    MockMvc mvc;

    record Tokens(String email, String access, String refresh) {
    }

    private static String uniqueEmail() {
        return "s" + UUID.randomUUID().toString().substring(0, 8) + "@campus.edu";
    }

    private Tokens register() throws Exception {
        String email = uniqueEmail();
        String body = """
                {"name":"Sesion Prueba","email":"%s","password":"%s","confirmPassword":"%s","acceptTerms":true}
                """.formatted(email, PASSWORD, PASSWORD);
        return parse(email, mvc.perform(post("/api/v1/auth/register").contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isCreated()).andReturn().getResponse().getContentAsString());
    }

    private Tokens login(String email, String password) throws Exception {
        String body = "{\"email\":\"%s\",\"password\":\"%s\"}".formatted(email, password);
        return parse(email, mvc.perform(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isOk()).andReturn().getResponse().getContentAsString());
    }

    private static Tokens parse(String email, String json) {
        return new Tokens(email, JsonPath.read(json, "$.token"), JsonPath.read(json, "$.refreshToken"));
    }

    private org.springframework.test.web.servlet.ResultActions refresh(String refreshToken) throws Exception {
        return mvc.perform(post("/api/v1/auth/refresh").contentType(MediaType.APPLICATION_JSON)
                .content("{\"refreshToken\":\"%s\"}".formatted(refreshToken)));
    }

    private int profileStatus(String access) throws Exception {
        return mvc.perform(get("/api/v1/profile").header("Authorization", "Bearer " + access))
                .andReturn().getResponse().getStatus();
    }

    @Test
    void logoutRevokesAccessTokenImmediately() throws Exception {
        Tokens t = register();
        org.junit.jupiter.api.Assertions.assertEquals(200, profileStatus(t.access()));

        mvc.perform(post("/api/v1/auth/logout").header("Authorization", "Bearer " + t.access()))
                .andExpect(status().isNoContent());

        org.junit.jupiter.api.Assertions.assertEquals(401, profileStatus(t.access()));
        refresh(t.refresh()).andExpect(status().isUnauthorized());
    }

    @Test
    void refreshRotatesTokenAndOldOneIsRejected() throws Exception {
        Tokens t = register();
        String json = refresh(t.refresh()).andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
        Tokens next = parse(t.email(), json);

        org.junit.jupiter.api.Assertions.assertNotEquals(t.refresh(), next.refresh());
        org.junit.jupiter.api.Assertions.assertEquals(200, profileStatus(next.access()));

        // Reutilizar el token viejo = posible robo: se rechaza y se revoca toda la sesión.
        refresh(t.refresh()).andExpect(status().isUnauthorized());
        refresh(next.refresh()).andExpect(status().isUnauthorized());
        org.junit.jupiter.api.Assertions.assertEquals(401, profileStatus(next.access()));
    }

    @Test
    void malformedAndForgedRefreshTokensAreRejected() throws Exception {
        Tokens t = register();
        refresh("sin-punto").andExpect(status().isUnauthorized());
        refresh(UUID.randomUUID() + ".falso").andExpect(status().isUnauthorized());
        String sid = t.refresh().substring(0, t.refresh().indexOf('.'));
        refresh(sid + ".secretoadivinado").andExpect(status().isUnauthorized());
    }

    @Test
    void accessTokenWithoutSessionClaimIsRejected() throws Exception {
        // JWT firmado con otro secreto / sin sid no debe aceptarse.
        mvc.perform(get("/api/v1/profile").header("Authorization",
                        "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.firma-invalida"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void sessionsAreListedAndRevocableIndividually() throws Exception {
        Tokens a = register();
        Tokens b = login(a.email(), PASSWORD);

        String list = mvc.perform(get("/api/v1/auth/sessions").header("Authorization", "Bearer " + a.access()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2))
                .andReturn().getResponse().getContentAsString();
        String otherId = b.refresh().substring(0, b.refresh().indexOf('.'));

        mvc.perform(delete("/api/v1/auth/sessions/" + otherId).header("Authorization", "Bearer " + a.access()))
                .andExpect(status().isNoContent());
        org.junit.jupiter.api.Assertions.assertEquals(401, profileStatus(b.access()));
        org.junit.jupiter.api.Assertions.assertEquals(200, profileStatus(a.access()));
        org.junit.jupiter.api.Assertions.assertTrue(list.contains(otherId));
    }

    @Test
    void userCannotRevokeAnotherUsersSession() throws Exception {
        Tokens victim = register();
        Tokens attacker = register();
        String victimSid = victim.refresh().substring(0, victim.refresh().indexOf('.'));

        mvc.perform(delete("/api/v1/auth/sessions/" + victimSid).header("Authorization", "Bearer " + attacker.access()))
                .andExpect(status().isNoContent());
        org.junit.jupiter.api.Assertions.assertEquals(200, profileStatus(victim.access()));
    }

    @Test
    void logoutAllClosesEverySession() throws Exception {
        Tokens a = register();
        Tokens b = login(a.email(), PASSWORD);
        mvc.perform(post("/api/v1/auth/logout-all").header("Authorization", "Bearer " + a.access()))
                .andExpect(status().isNoContent());
        org.junit.jupiter.api.Assertions.assertEquals(401, profileStatus(a.access()));
        org.junit.jupiter.api.Assertions.assertEquals(401, profileStatus(b.access()));
    }

    @Test
    void repeatedFailedLoginsAreThrottled() throws Exception {
        Tokens t = register();
        String bad = "{\"email\":\"%s\",\"password\":\"Incorrecta1\"}".formatted(t.email());
        for (int i = 0; i < 5; i++) {
            mvc.perform(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON).content(bad))
                    .andExpect(status().isUnauthorized());
        }
        mvc.perform(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON).content(bad))
                .andExpect(status().isTooManyRequests());
        // Incluso con la contraseña correcta, mientras dure el bloqueo.
        mvc.perform(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"%s\",\"password\":\"%s\"}".formatted(t.email(), PASSWORD)))
                .andExpect(status().isTooManyRequests());
    }

    @Test
    void securityHeadersArePresent() throws Exception {
        mvc.perform(get("/api/v1/profile"))
                .andExpect(status().isUnauthorized())
                .andExpect(header().string("X-Content-Type-Options", "nosniff"))
                .andExpect(header().string("X-Frame-Options", "DENY"))
                .andExpect(header().string("Referrer-Policy", "no-referrer"))
                .andExpect(header().string("Content-Security-Policy", "default-src 'none'; frame-ancestors 'none'"))
                .andExpect(header().string("Cache-Control", org.hamcrest.Matchers.containsString("no-store")));
    }
}
