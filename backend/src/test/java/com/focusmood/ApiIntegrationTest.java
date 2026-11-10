package com.focusmood;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
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
import org.springframework.test.web.servlet.ResultActions;

/** Flujo completo contra H2 con el mismo esquema Flyway. Sin GEMINI_API_KEY: ejercita el respaldo (RF-30). */
@SpringBootTest
@AutoConfigureMockMvc
class ApiIntegrationTest {

    private static final String PASSWORD = "Clave1234";

    @Autowired
    MockMvc mvc;

    private String register(String email) throws Exception {
        String body = """
                {"name":"Estudiante Prueba","email":"%s","password":"%s","confirmPassword":"%s","acceptTerms":true}
                """.formatted(email, PASSWORD, PASSWORD);
        String response = mvc.perform(post("/api/v1/auth/register").contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.token", notNullValue()))
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(response, "$.token");
    }

    private static String uniqueEmail() {
        return "u" + UUID.randomUUID().toString().substring(0, 8) + "@campus.edu";
    }

    private ResultActions json(org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder b,
                               String token, String body) throws Exception {
        return mvc.perform(b.header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON).content(body));
    }

    private ResultActions authed(org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder b,
                                 String token) throws Exception {
        return mvc.perform(b.header("Authorization", "Bearer " + token));
    }

    @Test
    void protectedEndpointsRequireAuthentication() throws Exception {
        mvc.perform(get("/api/v1/habits")).andExpect(status().isUnauthorized());
        mvc.perform(get("/api/v1/habits").header("Authorization", "Bearer token-falso"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void registrationValidatesAndRejectsDuplicates() throws Exception {
        String email = uniqueEmail();
        register(email);

        String dup = """
                {"name":"Otro","email":"%s","password":"%s","confirmPassword":"%s","acceptTerms":true}
                """.formatted(email.toUpperCase(), PASSWORD, PASSWORD);
        mvc.perform(post("/api/v1/auth/register").contentType(MediaType.APPLICATION_JSON).content(dup))
                .andExpect(status().isConflict());

        String weak = """
                {"name":"X","email":"%s","password":"corta","confirmPassword":"distinta","acceptTerms":false}
                """.formatted(uniqueEmail());
        mvc.perform(post("/api/v1/auth/register").contentType(MediaType.APPLICATION_JSON).content(weak))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors.password", notNullValue()));
    }

    @Test
    void loginSucceedsWithValidCredentialsAndFailsOtherwise() throws Exception {
        String email = uniqueEmail();
        register(email);
        mvc.perform(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"%s\",\"password\":\"%s\"}".formatted(email, PASSWORD)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.tokenType").value("Bearer"));
        mvc.perform(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"%s\",\"password\":\"Incorrecta1\"}".formatted(email)))
                .andExpect(status().isUnauthorized());
        mvc.perform(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"nadie@campus.edu\",\"password\":\"Incorrecta1\"}"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void profileCanBeReadAndUpdated() throws Exception {
        String token = register(uniqueEmail());
        json(put("/api/v1/profile"), token,
                "{\"name\":\"Nuevo Nombre\",\"career\":\"Ingeniería de Sistemas\",\"semester\":7}")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Nuevo Nombre"));
        authed(get("/api/v1/profile"), token)
                .andExpect(jsonPath("$.career").value("Ingeniería de Sistemas"))
                .andExpect(jsonPath("$.semester").value(7));
        json(put("/api/v1/profile"), token, "{\"name\":\"X\",\"semester\":40}").andExpect(status().isBadRequest());
    }

    @Test
    void dailyLogToRecommendationToRatingFlow() throws Exception {
        String token = register(uniqueEmail());

        String logBody = "{\"mood\":\"CANSADO\",\"energyLevel\":2,\"concentrationLevel\":3,\"note\":\"Poco sueño\"}";
        String logResponse = json(post("/api/v1/daily-logs"), token, logBody)
                .andExpect(status().isCreated()).andReturn().getResponse().getContentAsString();
        int logId = JsonPath.read(logResponse, "$.id");

        // Solo un registro por fecha
        json(post("/api/v1/daily-logs"), token, logBody).andExpect(status().isConflict());
        json(post("/api/v1/daily-logs"), token, "{\"mood\":\"FELIZ\",\"energyLevel\":9,\"concentrationLevel\":3}")
                .andExpect(status().isBadRequest());

        String recBody = "{\"dailyLogId\":%d,\"availableMinutes\":20,\"academicActivity\":\"Repasar estadística\"}"
                .formatted(logId);
        String recResponse = json(post("/api/v1/recommendations"), token, recBody)
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.durationMinutes").isNumber())
                .andExpect(jsonPath("$.instructions", notNullValue()))
                .andExpect(jsonPath("$.source").value("reglas-locales"))
                .andExpect(jsonPath("$.disclaimer", containsString("no reemplazan")))
                .andReturn().getResponse().getContentAsString();
        int recId = JsonPath.read(recResponse, "$.id");

        // Valoración idempotente: la segunda actualiza la primera
        json(put("/api/v1/recommendations/" + recId + "/rating"), token, "{\"score\":5}")
                .andExpect(status().isOk()).andExpect(jsonPath("$.rating.helpful").value(true));
        json(put("/api/v1/recommendations/" + recId + "/rating"), token, "{\"score\":1,\"comment\":\"No\"}")
                .andExpect(status().isOk()).andExpect(jsonPath("$.rating.helpful").value(false));

        authed(get("/api/v1/recommendations"), token)
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].rating.score").value(1));
    }

    @Test
    void usersCannotAccessEachOthersData() throws Exception {
        String owner = register(uniqueEmail());
        String intruder = register(uniqueEmail());

        String habit = json(post("/api/v1/habits"), owner, "{\"name\":\"Leer\",\"frequency\":\"DAILY\"}")
                .andExpect(status().isCreated()).andReturn().getResponse().getContentAsString();
        int habitId = JsonPath.read(habit, "$.id");

        authed(get("/api/v1/habits/" + habitId), intruder).andExpect(status().isNotFound());
        authed(delete("/api/v1/habits/" + habitId), intruder).andExpect(status().isNotFound());
        json(post("/api/v1/habits/" + habitId + "/completions"), intruder, "{}").andExpect(status().isNotFound());
        authed(get("/api/v1/habits"), intruder).andExpect(jsonPath("$.length()").value(0));

        String log = json(post("/api/v1/daily-logs"), owner,
                "{\"mood\":\"NEUTRAL\",\"energyLevel\":3,\"concentrationLevel\":3}")
                .andReturn().getResponse().getContentAsString();
        int logId = JsonPath.read(log, "$.id");
        json(post("/api/v1/recommendations"), intruder,
                "{\"dailyLogId\":%d,\"availableMinutes\":20,\"academicActivity\":\"x\"}".formatted(logId))
                .andExpect(status().isNotFound());
    }

    @Test
    void habitCompletionIsNotDuplicatedAndCanBeUndone() throws Exception {
        String token = register(uniqueEmail());
        String habit = json(post("/api/v1/habits"), token,
                "{\"name\":\"Tomar agua\",\"frequency\":\"DAILY\",\"schedule\":\"MORNING\"}")
                .andReturn().getResponse().getContentAsString();
        int id = JsonPath.read(habit, "$.id");

        json(post("/api/v1/habits/" + id + "/completions"), token, "{\"note\":\"6 vasos\"}")
                .andExpect(status().isCreated());
        json(post("/api/v1/habits/" + id + "/completions"), token, "{}").andExpect(status().isConflict());
        authed(get("/api/v1/habits/" + id), token).andExpect(jsonPath("$.completedToday").value(true));

        String today = JsonPath.read(
                authed(get("/api/v1/habits/" + id + "/completions"), token).andReturn().getResponse().getContentAsString(),
                "$[0].date");
        authed(delete("/api/v1/habits/" + id + "/completions/" + today), token).andExpect(status().isNoContent());
        authed(get("/api/v1/habits/" + id), token).andExpect(jsonPath("$.completedToday").value(false));

        json(post("/api/v1/habits/" + id + "/completions"), token, "{\"date\":\"2999-01-01\"}")
                .andExpect(status().isUnprocessableEntity());
    }

    @Test
    void studySessionsAreRecordedOnceAndSummarised() throws Exception {
        String token = register(uniqueEmail());
        String started = java.time.Instant.now().minusSeconds(1800).toString();
        String body = """
                {"startedAt":"%s","activity":"Cálculo","durationMinutes":25,"status":"COMPLETED",
                 "cycles":[{"focusMinutes":25,"breakMinutes":5,"completedCycles":1,"status":"COMPLETED"}]}
                """.formatted(started);
        json(post("/api/v1/study-sessions"), token, body)
                .andExpect(status().isCreated()).andExpect(jsonPath("$.totalCompletedCycles").value(1));
        json(post("/api/v1/study-sessions"), token, body).andExpect(status().isConflict());
        json(post("/api/v1/study-sessions"), token, body.replace("\"durationMinutes\":25", "\"durationMinutes\":0")
                .replace(started, java.time.Instant.now().minusSeconds(900).toString()))
                .andExpect(status().isBadRequest());

        authed(get("/api/v1/progress/weekly"), token)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.hasData").value(true))
                .andExpect(jsonPath("$.study.sessions").value(1))
                .andExpect(jsonPath("$.study.totalMinutes").value(25));
    }

    @Test
    void emptyWeeklySummaryExplainsInsteadOfInventingData() throws Exception {
        String token = register(uniqueEmail());
        authed(get("/api/v1/progress/weekly"), token)
                .andExpect(jsonPath("$.hasData").value(false))
                .andExpect(jsonPath("$.message", notNullValue()))
                .andExpect(jsonPath("$.study.sessions").value(0));
    }

    @Test
    void wellnessCatalogAndLogWork() throws Exception {
        String token = register(uniqueEmail());
        String list = authed(get("/api/v1/wellness/activities?category=RESPIRAR"), token)
                .andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
        int activityId = JsonPath.read(list, "$[0].id");
        json(post("/api/v1/wellness/logs"), token, "{\"activityId\":%d}".formatted(activityId))
                .andExpect(status().isCreated()).andExpect(jsonPath("$.completed").value(true));
        authed(get("/api/v1/progress/weekly"), token).andExpect(jsonPath("$.wellnessActivitiesCompleted").value(1));
    }

    @Test
    void remindersValidateHabitOwnershipAndSchedule() throws Exception {
        String owner = register(uniqueEmail());
        String other = register(uniqueEmail());
        String habit = json(post("/api/v1/habits"), owner, "{\"name\":\"Dormir\",\"frequency\":\"DAILY\"}")
                .andReturn().getResponse().getContentAsString();
        int habitId = JsonPath.read(habit, "$.id");
        String future = java.time.Instant.now().plusSeconds(3600).toString();

        String body = "{\"title\":\"Dormir\",\"type\":\"HABIT\",\"habitId\":%d,\"scheduledAt\":\"%s\",\"frequency\":\"DAILY\"}"
                .formatted(habitId, future);
        String created = json(post("/api/v1/reminders"), owner, body).andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        json(post("/api/v1/reminders"), other, body).andExpect(status().isNotFound());

        int id = JsonPath.read(created, "$.id");
        json(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch("/api/v1/reminders/" + id + "/active"),
                owner, "{\"active\":false}").andExpect(jsonPath("$.active").value(false));

        String past = java.time.Instant.now().minusSeconds(3600).toString();
        json(post("/api/v1/reminders"), owner,
                "{\"title\":\"Pasado\",\"type\":\"GENERAL\",\"scheduledAt\":\"%s\",\"frequency\":\"ONCE\"}".formatted(past))
                .andExpect(status().isUnprocessableEntity());
    }

    @Test
    void passwordRecoveryRejectsUnknownEmailAndInvalidToken() throws Exception {
        String email = uniqueEmail();
        register(email);
        mvc.perform(post("/api/v1/auth/forgot-password").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"%s\"}".formatted(email)))
                .andExpect(status().isAccepted());
        mvc.perform(post("/api/v1/auth/forgot-password").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"nadie@campus.edu\"}"))
                .andExpect(status().isAccepted());
        mvc.perform(post("/api/v1/auth/reset-password").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"token\":\"falso\",\"newPassword\":\"Nueva1234\",\"confirmPassword\":\"Nueva1234\"}"))
                .andExpect(status().isUnprocessableEntity());
    }
}
