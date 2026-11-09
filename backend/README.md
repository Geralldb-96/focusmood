# FocusMood · Backend

API REST (Java 21, Spring Boot 4.1, PostgreSQL, JWT) según el documento de planeación y diseño.

## Ejecutar

Guía completa (Docker, Flutter, APK, problemas frecuentes) en el [README de la raíz](../README.md#puesta-en-marcha). Resumen:

```sh
# desde la raíz del repo: crea .env con JWT_SECRET=<mín. 32 caracteres>, luego
docker compose up -d db                 # PostgreSQL 17
cd backend
SPRING_PROFILES_ACTIVE=dev ./mvnw spring-boot:run     # Windows PowerShell: $env:SPRING_PROFILES_ACTIVE="dev"; .\mvnw.cmd spring-boot:run
./mvnw test                             # pruebas (H2 con el mismo esquema Flyway; no necesitan Docker)
```

También puedes levantar todo con `docker compose up -d --build` (usa el `Dockerfile` de esta carpeta).

Variables de entorno (nunca van en el código, RNF-08):

| Variable | Obligatoria | Descripción |
|---|---|---|
| `JWT_SECRET` | sí (en `dev` hay un valor de desarrollo) | Secreto HS256, mínimo 32 caracteres |
| `DB_URL`, `DB_USER`, `DB_PASSWORD` | sí | Conexión PostgreSQL |
| `GEMINI_API_KEY` | no | Sin clave se usa siempre la recomendación de respaldo por reglas (RF-30) |
| `GEMINI_MODEL` | no | Por defecto `gemini-2.5-flash` |
| `CORS_ALLOWED_ORIGINS` | no | Orígenes del frontend, separados por coma |
| `APP_ZONE` | no | Zona horaria de "hoy" (por defecto `America/Bogota`) |

## Arquitectura (capas por módulo)

`Controller → Service (interfaz + Impl) → Repository → PostgreSQL`

Módulos (`com.focusmood.*`): `user`, `daily`, `recommendation`, `habit`, `study`, `wellness`, `reminder`, `progress`, más `security` y `common`.

Cómo se aplica SOLID:

- **S**: cada clase tiene una sola razón de cambio. `AuthService`, `PasswordRecoveryService` y `ProfileService` están separados; `PromptBuilder`, `GeminiRecommendationGenerator`, `SafetyRecommendationValidator` y `RuleBasedRecommendationGenerator` se reparten el trabajo de la IA.
- **O**: nuevas técnicas, actividades o proveedores de IA se agregan con nuevas implementaciones (`StudyTechniqueCatalog`, `RecommendationGenerator`, `PasswordResetNotifier`, `TokenIssuer`) sin modificar a los consumidores. `HabitFrequency` calcula su propio cumplimiento esperado (polimorfismo en lugar de `switch`).
- **L**: cualquier `RecommendationGenerator` es sustituible; `ResilientRecommendationGenerator` lo decora sin alterar el contrato.
- **I**: interfaces pequeñas y específicas (`MoodStats`, `HabitStats`, `StudyStats`, `WellnessStats`, `RecommendationStats`) en lugar de exponer los servicios completos al módulo de progreso.
- **D**: los servicios dependen de interfaces (`TokenIssuer`, `RecommendationGenerator`, `RecommendationValidator`, `PasswordResetNotifier`, `Clock`), no de implementaciones concretas.

## Endpoints (`/api/v1`, JSON, JWT `Authorization: Bearer …`)

| Módulo | Endpoints | Historias |
|---|---|---|
| Auth | Público: `POST /auth/register`, `/auth/login`, `/auth/refresh`, `/auth/forgot-password`, `/auth/reset-password`. Autenticado: `POST /auth/logout`, `/auth/logout-all`, `GET /auth/sessions`, `DELETE /auth/sessions/{id}` | FCM-01/02/03/17 |
| Perfil | `GET`/`PUT /profile` | FCM-04 |
| Registro diario | `POST /daily-logs`, `GET /daily-logs?from&to`, `GET /daily-logs/today`, `GET`/`PUT /daily-logs/{id}` | FCM-05 |
| Recomendaciones | `POST /recommendations`, `GET /recommendations`, `GET /recommendations/{id}`, `PUT /recommendations/{id}/rating` | FCM-06/07/08/09 |
| Hábitos | CRUD `/habits`, `POST`/`GET /habits/{id}/completions`, `DELETE /habits/{id}/completions/{fecha}` | FCM-10/11 |
| Estudio | `POST`/`GET /study-sessions`, `GET /study-sessions/{id}`, `GET /study-techniques` | FCM-12/13 |
| Bienestar | `GET /wellness/activities?category`, `GET /wellness/activities/{id}`, `POST`/`GET /wellness/logs` | FCM-14 |
| Progreso | `GET /progress/weekly?date=` | FCM-15 |
| Recordatorios | CRUD `/reminders`, `PATCH /reminders/{id}/active` | FCM-16 |

Errores: RFC 9457 (`ProblemDetail`); los de validación incluyen `errors` por campo.

## Decisiones y desviaciones respecto al documento

- **Escala 1-5** para energía y concentración (modelo relacional, 4.4.2). El prototipo del frontend usa sliders 0-10: hay que adaptarlo o mapearlo.
- **Estado de ánimo**: enum (`ESTRESADO … FELIZ`) con valencia 1-5 para promedios; el frontend hoy usa un slider.
- **Extensiones al modelo**: tabla `token_recuperacion` (FCM-03, solo se guarda el hash SHA-256); en `recomendacion` las columnas `titulo`, `tecnica` y `duracion_minutos` (RF-10); en `habito` la columna `horario`.
- **Recuperación de contraseña**: `forgot-password` responde 202 exista o no el correo, para no permitir enumerar cuentas (se aparta del criterio FCM-03, que pedía informar si el correo no existe). El envío real de correo queda tras la interfaz `PasswordResetNotifier`; la implementación actual solo registra en log.
- **Cierre de sesión**: el access token (15 min por defecto, `JWT_TTL`) va ligado a una sesión en servidor; el refresh token (7 días, `REFRESH_TTL`) rota en cada renovación. Cerrar sesión o revocarla invalida el token al instante.
- **IA**: solo se envían ánimo, energía, concentración, tiempo y actividad (RNF-10). La respuesta se valida (sin contenido clínico u ofensivo, duración ≤ tiempo disponible); ante cualquier fallo se usa la recomendación de respaldo y `source` indica `reglas-locales`.
- **Temporizador Pomodoro**: corre en el dispositivo; el backend registra la sesión terminada. Las notificaciones son locales (Capacitor); el backend solo guarda la configuración del recordatorio.
- **Sin probar**: la llamada real a Gemini (no hay clave en este entorno). El resto se verificó con pruebas y contra PostgreSQL real.
