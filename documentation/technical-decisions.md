# Registro de decisiones técnicas

Las decisiones aceptadas se mantienen hasta que otra decisión las sustituya explícitamente.

| ID | Fecha | Estado | Decisión | Motivo | Consecuencias |
| --- | --- | --- | --- | --- | --- |
| ADR-001 | 2026-11-08 | Aceptada | Mantener Flutter y Dart como aplicación cliente. | Conserva el lenguaje y el trabajo actual solicitado por el proyecto. | La guía académica se actualizará para sustituir Ionic, Angular y Capacitor. |
| ADR-002 | 2026-11-08 | Aceptada | Implementar el backend con Java 21, Spring Boot y Maven. | Coincide con la arquitectura de la guía y separa secretos y reglas del cliente. | El entorno de backend debe fijar JDK 21 aunque el sistema tenga otras versiones. |
| ADR-003 | 2026-11-08 | Aceptada | Usar PostgreSQL y Flyway como fuente de información y control de esquema. | Permite integridad relacional, historial de migraciones y respaldos restaurables. | `shared_preferences` queda limitado a preferencias o caché no sensible. |
| ADR-004 | 2026-11-08 | Aceptada | Integrar Gemini exclusivamente desde el backend y comenzar con el nivel gratuito. | Evita exponer la clave en Flutter y limita costos durante el desarrollo. | Se requieren límites, observación de cuota y una recomendación local segura de respaldo. |
| ADR-005 | 2026-11-08 | Aceptada | Publicar una API REST JSON bajo `/api/v1` y describirla con OpenAPI. | Facilita la separación cliente-servidor, las pruebas y la evolución compatible. | Todo endpoint debe mantener contrato, ejemplos, errores y autenticación documentados. |
| ADR-006 | 2026-11-08 | Aceptada | Convertir el repositorio en un monorepo. | Mantiene móvil, backend, base de datos, infraestructura, pruebas y documentación coordinados. | El proyecto Flutter se moverá a `mobile/` conservando su historial Git. |
| ADR-007 | 2026-11-08 | Aceptada | Usar Docker Compose localmente y Kubernetes para staging y producción. | Permite reproducibilidad local y satisface el requisito de despliegue. | Se deben administrar secretos, persistencia, probes, recursos, migraciones y rollback. |
| ADR-008 | 2026-11-08 | Aceptada | Usar JWT de acceso y refresh tokens rotatorios. | Permite sesiones móviles revocables sin mantener contraseñas en el dispositivo. | Flutter usará almacenamiento seguro e interceptor con renovación coordinada. |
| ADR-009 | 2026-11-08 | Aceptada | Usar notificaciones locales para recordatorios y finalización del Pomodoro. | Los avisos principales no requieren un proveedor push externo. | Deben respetarse permisos, zona horaria, reprogramación y cancelación. |
| ADR-010 | 2026-11-08 | Aceptada | Guardar fechas del servidor en UTC y usar `TIMESTAMPTZ`. | Evita ambigüedad entre dispositivo, servidor y despliegues. | La aplicación convierte las fechas a la zona horaria del usuario al mostrarlas. |

## Cómo añadir una decisión

1. Crear el siguiente identificador ADR disponible.
2. Describir el contexto y las alternativas consideradas.
3. Marcarla como `Propuesta`, `Aceptada`, `Rechazada` o `Sustituida`.
4. Indicar qué archivos, migraciones o despliegues quedan afectados.
5. Si reemplaza otra decisión, enlazar ambas filas y conservar el historial.
