# API REST · FocusMood

Documentación de los endpoints del backend. Base URL local: `http://localhost:8080/api/v1`.

## Convenciones

- **Formato:** JSON (`Content-Type: application/json`).
- **Autenticación:** JWT (HS256) en la cabecera `Authorization: Bearer <token>`. Solo los endpoints marcados como **Público** no lo requieren.
- **Sesiones:** cada token está ligado a una sesión (`sid`). Si la sesión se revoca (logout, `DELETE /auth/sessions/{id}`) o expira, el token deja de valer de inmediato.
- **Fechas:** `LocalDate` en formato `yyyy-MM-dd`; instantes (`Instant`) en ISO-8601 UTC, por ejemplo `2026-11-05T14:30:00Z`.
- **Zona horaria:** "hoy" se calcula con `APP_ZONE` (por defecto `America/Bogota`).
- **Aislamiento:** cada usuario solo accede a sus propios recursos; un recurso ajeno responde `404`.
- **CORS:** métodos `GET, POST, PUT, PATCH, DELETE, OPTIONS`; cabeceras `Authorization` y `Content-Type`; orígenes según `CORS_ALLOWED_ORIGINS`.

## Errores

Los errores siguen RFC 9457 (`ProblemDetail`):

```json
{
  "type": "about:blank",
  "title": "Bad Request",
  "status": 400,
  "detail": "Hay datos que debes corregir.",
  "errors": { "email": "El correo no tiene un formato válido" }
}
```

`errors` solo aparece en validaciones (`400`) y mapea campo → mensaje.

| Código | Cuándo ocurre |
| --- | --- |
| `400` | Validación fallida o cuerpo/parámetro con formato inválido |
| `401` | Credenciales incorrectas, token ausente, inválido, expirado o sesión revocada |
| `404` | El recurso no existe o no pertenece al usuario |
| `409` | Conflicto con datos ya registrados (por ejemplo, correo duplicado) |
| `422` | Regla de negocio incumplida |
| `429` | Demasiadas solicitudes (login / recuperación de contraseña) |
| `500` | Error inesperado (el detalle no se expone al cliente) |

## Índice de endpoints

| Módulo | Método | Ruta | Auth | Descripción |
| --- | --- | --- | --- | --- |
| Auth | POST | `/auth/register` | Público | Registrar usuario |
| Auth | POST | `/auth/login` | Público | Iniciar sesión |
| Auth | POST | `/auth/refresh` | Público | Renovar sesión |
| Auth | POST | `/auth/forgot-password` | Público | Solicitar recuperación |
| Auth | POST | `/auth/reset-password` | Público | Restablecer contraseña |
| Auth | POST | `/auth/logout` | JWT | Cerrar la sesión actual |
| Auth | POST | `/auth/logout-all` | JWT | Cerrar todas las sesiones |
| Auth | GET | `/auth/sessions` | JWT | Listar sesiones activas |
| Auth | DELETE | `/auth/sessions/{id}` | JWT | Revocar una sesión |
| Perfil | GET | `/profile` | JWT | Obtener perfil |
| Perfil | PUT | `/profile` | JWT | Actualizar perfil |
| Registro diario | POST | `/daily-logs` | JWT | Crear registro emocional |
| Registro diario | GET | `/daily-logs` | JWT | Historial (con rango) |
| Registro diario | GET | `/daily-logs/today` | JWT | Registro de hoy |
| Registro diario | GET | `/daily-logs/{id}` | JWT | Detalle |
| Registro diario | PUT | `/daily-logs/{id}` | JWT | Editar |
| Recomendaciones | POST | `/recommendations` | JWT | Generar recomendación |
| Recomendaciones | GET | `/recommendations` | JWT | Historial |
| Recomendaciones | GET | `/recommendations/{id}` | JWT | Detalle |
| Recomendaciones | PUT | `/recommendations/{id}/rating` | JWT | Valorar |
| Hábitos | POST | `/habits` | JWT | Crear hábito |
| Hábitos | GET | `/habits` | JWT | Listar hábitos |
| Hábitos | GET | `/habits/{id}` | JWT | Detalle |
| Hábitos | PUT | `/habits/{id}` | JWT | Editar |
| Hábitos | DELETE | `/habits/{id}` | JWT | Eliminar |
| Hábitos | POST | `/habits/{id}/completions` | JWT | Marcar cumplimiento |
| Hábitos | GET | `/habits/{id}/completions` | JWT | Listar cumplimientos |
| Hábitos | DELETE | `/habits/{id}/completions/{date}` | JWT | Deshacer cumplimiento |
| Sesiones de estudio | POST | `/study-sessions` | JWT | Registrar sesión |
| Sesiones de estudio | GET | `/study-sessions` | JWT | Historial (con rango) |
| Sesiones de estudio | GET | `/study-sessions/{id}` | JWT | Detalle |
| Sesiones de estudio | GET | `/study-techniques` | JWT | Catálogo de técnicas |
| Bienestar | GET | `/wellness/activities` | JWT | Catálogo de actividades |
| Bienestar | GET | `/wellness/activities/{id}` | JWT | Detalle de actividad |
| Bienestar | POST | `/wellness/logs` | JWT | Registrar actividad realizada |
| Bienestar | GET | `/wellness/logs` | JWT | Historial (con rango) |
| Recordatorios | POST | `/reminders` | JWT | Crear recordatorio |
| Recordatorios | GET | `/reminders` | JWT | Listar |
| Recordatorios | GET | `/reminders/{id}` | JWT | Detalle |
| Recordatorios | PUT | `/reminders/{id}` | JWT | Editar |
| Recordatorios | PATCH | `/reminders/{id}/active` | JWT | Activar / desactivar |
| Recordatorios | DELETE | `/reminders/{id}` | JWT | Eliminar |
| Progreso | GET | `/progress/weekly` | JWT | Resumen semanal |

---

## Auth

### POST `/auth/register` · Público

Crea la cuenta e inicia sesión. Responde `201` con un [`AuthResponse`](#authresponse).

```json
{
  "name": "Ana Pérez",
  "email": "ana@correo.com",
  "password": "Clave1234",
  "confirmPassword": "Clave1234",
  "acceptTerms": true
}
```

| Campo | Reglas |
| --- | --- |
| `name` | Obligatorio, máx. 120 |
| `email` | Obligatorio, formato de correo, máx. 150 |
| `password` | 8–64 caracteres, al menos una letra y un número |
| `confirmPassword` | Debe coincidir con `password` |
| `acceptTerms` | Debe ser `true` |

### POST `/auth/login` · Público

```json
{ "email": "ana@correo.com", "password": "Clave1234" }
```

Responde `200` con un [`AuthResponse`](#authresponse). Credenciales incorrectas → `401`; demasiados intentos fallidos → `429`.

### POST `/auth/refresh` · Público

Renueva la sesión. El refresh token se **rota**: el anterior deja de servir.

```json
{ "refreshToken": "..." }
```

Responde `200` con un [`AuthResponse`](#authresponse).

### POST `/auth/forgot-password` · Público

Solicita el enlace de recuperación. Responde `202` sin cuerpo. Está limitado por IP (`429` si se excede).

```json
{ "email": "ana@correo.com" }
```

### POST `/auth/reset-password` · Público

Responde `204`.

```json
{
  "token": "token-recibido",
  "newPassword": "NuevaClave123",
  "confirmPassword": "NuevaClave123"
}
```

### POST `/auth/logout` · JWT

Revoca la sesión del token presentado. Responde `204`.

### POST `/auth/logout-all` · JWT

Revoca todas las sesiones del usuario. Responde `204`.

### GET `/auth/sessions` · JWT

Lista las sesiones activas. `current` indica la sesión del token usado.

```json
[
  {
    "id": "a1b2...",
    "device": "Chrome en Windows",
    "ip": "190.1.2.3",
    "createdAt": "2026-11-05T14:00:00Z",
    "lastUsedAt": "2026-11-05T14:30:00Z",
    "expiresAt": "2026-11-05T22:00:00Z",
    "current": true
  }
]
```

### DELETE `/auth/sessions/{id}` · JWT

Revoca la sesión indicada. Responde `204`.

#### AuthResponse

```json
{
  "token": "eyJ...",
  "tokenType": "Bearer",
  "expiresAt": "2026-11-06T02:00:00Z",
  "refreshToken": "...",
  "user": { "id": 1, "name": "Ana Pérez", "email": "ana@correo.com" }
}
```

---

## Perfil

### GET `/profile` · JWT

```json
{
  "userId": 1,
  "name": "Ana Pérez",
  "email": "ana@correo.com",
  "career": "Ingeniería de Sistemas",
  "semester": 5,
  "preferences": "Estudio de noche",
  "photoUrl": null
}
```

### PUT `/profile` · JWT

Reemplaza los datos editables y devuelve el perfil actualizado.

| Campo | Reglas |
| --- | --- |
| `name` | Obligatorio, máx. 120 |
| `career` | Máx. 120 |
| `semester` | 1–20 |
| `preferences` | Máx. 2000 |
| `photoUrl` | Máx. 500 |

---

## Registro diario

`mood` admite: `ESTRESADO`, `ANSIOSO`, `TRISTE`, `CANSADO`, `NEUTRAL`, `CALMADO`, `MOTIVADO`, `FELIZ`.

### POST `/daily-logs` · JWT

Responde `201`.

```json
{
  "mood": "MOTIVADO",
  "energyLevel": 4,
  "concentrationLevel": 3,
  "note": "Buen día",
  "date": "2026-11-05"
}
```

| Campo | Reglas |
| --- | --- |
| `mood` | Obligatorio |
| `energyLevel` | Obligatorio, 1–5 |
| `concentrationLevel` | Obligatorio, 1–5 |
| `note` | Máx. 500 |
| `date` | Opcional; por defecto hoy |

Respuesta:

```json
{
  "id": 10,
  "date": "2026-11-05",
  "recordedAt": "2026-11-05T14:30:00Z",
  "mood": "MOTIVADO",
  "energyLevel": 4,
  "concentrationLevel": 3,
  "note": "Buen día"
}
```

### GET `/daily-logs` · JWT

Historial. Parámetros opcionales: `from`, `to` (`yyyy-MM-dd`).

### GET `/daily-logs/today` · JWT

Registro de hoy.

### GET `/daily-logs/{id}` · JWT

Detalle de un registro.

### PUT `/daily-logs/{id}` · JWT

Edita un registro. Mismo cuerpo que la creación.

---

## Recomendaciones

Las recomendaciones son orientativas y educativas; no reemplazan la orientación médica o psicológica (el campo `disclaimer` lo recuerda en cada respuesta). Se generan con Gemini si hay `GEMINI_API_KEY`, y con reglas locales como respaldo.

### POST `/recommendations` · JWT

Responde `201`.

```json
{
  "dailyLogId": 10,
  "availableMinutes": 45,
  "academicActivity": "Estudiar para el parcial de cálculo"
}
```

| Campo | Reglas |
| --- | --- |
| `dailyLogId` | Obligatorio; registro diario de referencia |
| `availableMinutes` | Obligatorio, 1–480 |
| `academicActivity` | Obligatorio, máx. 200 |

Respuesta:

```json
{
  "id": 5,
  "category": "STUDY_TECHNIQUE",
  "title": "Bloques cortos de enfoque",
  "technique": "Pomodoro",
  "durationMinutes": 25,
  "instructions": "…",
  "source": "rule-based",
  "generatedAt": "2026-11-05T14:31:00Z",
  "context": {
    "date": "2026-11-05",
    "mood": "MOTIVADO",
    "energyLevel": 4,
    "concentrationLevel": 3,
    "availableMinutes": 45,
    "academicActivity": "Estudiar para el parcial de cálculo"
  },
  "rating": null,
  "disclaimer": "Las recomendaciones son orientativas y educativas; no reemplazan la orientación médica o psicológica."
}
```

`category`: `STUDY_TECHNIQUE` o `WELLNESS_ACTIVITY`.

### GET `/recommendations` · JWT

Historial de recomendaciones.

### GET `/recommendations/{id}` · JWT

Detalle de una recomendación.

### PUT `/recommendations/{id}/rating` · JWT

Valora una recomendación. Es **idempotente**: repetir la llamada actualiza la valoración existente.

```json
{ "score": 5, "comment": "Me sirvió" }
```

| Campo | Reglas |
| --- | --- |
| `score` | Obligatorio, 1–5 (la app puede mapear "No me sirvió" a 1 y "Me sirvió" a 5) |
| `comment` | Máx. 500 |

---

## Hábitos

Valores: `frequency` → `DAILY`, `WEEKDAYS`, `WEEKLY`; `schedule` → `MORNING`, `AFTERNOON`, `NIGHT`.

### POST `/habits` · JWT

Responde `201`.

```json
{
  "name": "Leer 20 minutos",
  "description": "Lectura antes de dormir",
  "frequency": "DAILY",
  "schedule": "NIGHT",
  "active": true
}
```

| Campo | Reglas |
| --- | --- |
| `name` | Obligatorio, máx. 100 |
| `description` | Máx. 500 |
| `frequency` | Obligatorio |
| `schedule` | Opcional |
| `active` | Opcional; por defecto `true` al crear y se conserva el valor actual si se omite al editar |

Respuesta:

```json
{
  "id": 3,
  "name": "Leer 20 minutos",
  "description": "Lectura antes de dormir",
  "frequency": "DAILY",
  "schedule": "NIGHT",
  "startDate": "2026-11-05",
  "active": true,
  "completedToday": false
}
```

### GET `/habits` · JWT

Lista los hábitos. Parámetro opcional `activeOnly` (`true`/`false`, por defecto `false`).

### GET `/habits/{id}` · JWT

Detalle de un hábito.

### PUT `/habits/{id}` · JWT

Edita un hábito. Mismo cuerpo que la creación.

### DELETE `/habits/{id}` · JWT

Responde `204`.

### POST `/habits/{id}/completions` · JWT

Marca un cumplimiento. El cuerpo es opcional. Responde `201`.

```json
{ "date": "2026-11-05", "note": "Terminé el capítulo 3" }
```

| Campo | Reglas |
| --- | --- |
| `date` | Opcional; por defecto hoy |
| `note` | Máx. 500 |

Respuesta:

```json
{ "id": 21, "habitId": 3, "date": "2026-11-05", "note": "Terminé el capítulo 3" }
```

### GET `/habits/{id}/completions` · JWT

Lista los cumplimientos. Parámetros opcionales: `from`, `to`.

### DELETE `/habits/{id}/completions/{date}` · JWT

Deshace el cumplimiento de esa fecha (`yyyy-MM-dd`). Responde `204`.

---

## Sesiones de estudio

`status` admite: `COMPLETED`, `INTERRUPTED`.

### POST `/study-sessions` · JWT

Registra una sesión finalizada en el temporizador del dispositivo. Responde `201`.

```json
{
  "startedAt": "2026-11-05T14:00:00Z",
  "endedAt": "2026-11-05T14:50:00Z",
  "activity": "Repaso de cálculo",
  "durationMinutes": 50,
  "status": "COMPLETED",
  "cycles": [
    { "focusMinutes": 25, "breakMinutes": 5, "completedCycles": 2, "status": "COMPLETED" }
  ]
}
```

| Campo | Reglas |
| --- | --- |
| `startedAt` | Obligatorio |
| `endedAt` | Opcional |
| `activity` | Obligatorio, máx. 200 |
| `durationMinutes` | Obligatorio, 1–720 |
| `status` | Obligatorio |
| `cycles` | Opcional, máx. 20 elementos |
| `cycles[].focusMinutes` | Obligatorio, 1–180 |
| `cycles[].breakMinutes` | Obligatorio, 1–60 |
| `cycles[].completedCycles` | Obligatorio, 0–50 |
| `cycles[].status` | Obligatorio |

Respuesta:

```json
{
  "id": 8,
  "startedAt": "2026-11-05T14:00:00Z",
  "endedAt": "2026-11-05T14:50:00Z",
  "activity": "Repaso de cálculo",
  "durationMinutes": 50,
  "status": "COMPLETED",
  "totalCompletedCycles": 2,
  "cycles": [
    { "id": 1, "focusMinutes": 25, "breakMinutes": 5, "completedCycles": 2, "status": "COMPLETED" }
  ]
}
```

### GET `/study-sessions` · JWT

Historial. Parámetros opcionales: `from`, `to`.

### GET `/study-sessions/{id}` · JWT

Detalle de una sesión.

### GET `/study-techniques` · JWT

Catálogo de técnicas de estudio.

```json
[
  { "code": "POMODORO", "name": "Pomodoro", "description": "…", "suggestedMinutes": 25 }
]
```

---

## Bienestar

`category` admite: `RESPIRAR`, `MOVERTE`, `DESCANSAR`.

### GET `/wellness/activities` · JWT

Catálogo de actividades. Parámetro opcional `category`.

```json
[
  {
    "id": 1,
    "name": "Respiración 4-7-8",
    "description": "…",
    "category": "RESPIRAR",
    "estimatedMinutes": 5
  }
]
```

### GET `/wellness/activities/{id}` · JWT

Detalle de una actividad.

### POST `/wellness/logs` · JWT

Registra una actividad realizada. Responde `201`.

```json
{ "activityId": 1, "completed": true, "note": "Me ayudó a relajarme" }
```

| Campo | Reglas |
| --- | --- |
| `activityId` | Obligatorio |
| `completed` | Opcional; por defecto `true` |
| `note` | Máx. 500 |

Respuesta:

```json
{
  "id": 14,
  "activityId": 1,
  "activityName": "Respiración 4-7-8",
  "performedAt": "2026-11-05T14:40:00Z",
  "completed": true,
  "note": "Me ayudó a relajarme"
}
```

### GET `/wellness/logs` · JWT

Historial. Parámetros opcionales: `from`, `to`.

---

## Recordatorios

Valores: `type` → `HABIT`, `STUDY_SESSION`, `DAILY_LOG`, `GENERAL`; `frequency` → `ONCE`, `DAILY`, `WEEKLY`.

### POST `/reminders` · JWT

Responde `201`.

```json
{
  "title": "Registrar cómo me siento",
  "type": "DAILY_LOG",
  "habitId": null,
  "scheduledAt": "2026-11-06T13:00:00Z",
  "frequency": "DAILY",
  "active": true
}
```

| Campo | Reglas |
| --- | --- |
| `title` | Obligatorio, máx. 120 |
| `type` | Obligatorio |
| `habitId` | Obligatorio si `type = HABIT`; en otros tipos se ignora |
| `scheduledAt` | Obligatorio (instante UTC) |
| `frequency` | Obligatorio |
| `active` | Opcional |

Respuesta:

```json
{
  "id": 2,
  "title": "Registrar cómo me siento",
  "type": "DAILY_LOG",
  "habitId": null,
  "scheduledAt": "2026-11-06T13:00:00Z",
  "frequency": "DAILY",
  "active": true
}
```

### GET `/reminders` · JWT

Lista los recordatorios.

### GET `/reminders/{id}` · JWT

Detalle de un recordatorio.

### PUT `/reminders/{id}` · JWT

Edita un recordatorio. Mismo cuerpo que la creación.

### PATCH `/reminders/{id}/active` · JWT

Activa o desactiva un recordatorio.

```json
{ "active": false }
```

### DELETE `/reminders/{id}` · JWT

Responde `204`.

---

## Progreso

### GET `/progress/weekly` · JWT

Resumen semanal calculado al vuelo (no se persiste). Parámetro opcional `date` (`yyyy-MM-dd`) para elegir la semana que contiene esa fecha; por defecto, la semana actual.

Campos de la respuesta:

| Campo | Descripción |
| --- | --- |
| `weekStart`, `weekEnd` | Límites de la semana |
| `hasData` | `false` si no hay ningún registro en el periodo; en ese caso `message` lo explica y las secciones vienen vacías, sin cifras inventadas |
| `message` | Texto explicativo cuando no hay datos |
| `mood` | Resumen de estados de ánimo |
| `habits` | Resumen de hábitos y cumplimiento |
| `study` | Resumen de sesiones de estudio |
| `wellnessActivitiesCompleted` | Actividades de bienestar completadas |
| `recommendations` | Resumen de recomendaciones y valoraciones |

> La estructura interna de `mood`, `habits`, `study` y `recommendations` la define el código de cada módulo (`MoodStats`, `HabitStats`, `StudyStats`, `RecommendationStats`).

---

## Notas

- `/actuator/health` está marcado como público en la configuración de seguridad, pero el proyecto aún no incluye la dependencia `spring-boot-starter-actuator`, por lo que ese endpoint no responde hasta añadirla.
- Los ejemplos de respuesta son ilustrativos; los nombres de campo y los tipos coinciden con los DTO del código.
