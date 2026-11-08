# Plan de sprints

La duración recomendada es de dos semanas. El orden puede ajustarse, pero no se omiten las dependencias ni los criterios de salida.

| Sprint | Objetivo | Trabajo principal | Criterio de salida |
| --- | --- | --- | --- |
| 0 | Preparar una base controlada | Puntos 1, 2 y 3; monorepo, configuración de ambientes y modularización inicial | Línea base reproducible, documentación de control y Flutter sin regresiones |
| 1 | Autenticación y perfiles reales | Backend base, PostgreSQL base, FCM-01, FCM-02, FCM-03, FCM-04 y FCM-17 | Registro, verificación, login, refresh, recuperación, perfil y logout con pruebas |
| 2 | Registro diario e IA | FCM-05 a FCM-09, Gemini, respaldo seguro y valoración | Recomendación real o de respaldo en menos de diez segundos, sin datos personales innecesarios |
| 3 | Hábitos y enfoque | FCM-10 a FCM-13 | Hábitos, cumplimientos, rachas, Pomodoro y sesiones persistidos en PostgreSQL |
| 4 | Bienestar, progreso y avisos | FCM-14, FCM-15 y FCM-16 | Catálogo real, resumen semanal calculado y notificaciones locales verificadas |
| 5 | Contrato y contenedores | OpenAPI, Swagger, Docker Compose y respaldos | API documentada; backend y PostgreSQL levantan con `docker compose up --build` |
| 6 | Seguridad y Kubernetes | Seguridad, privacidad y despliegues staging/production | HTTPS, secretos externos, probes, recursos, migraciones y rollback comprobados |
| 7 | Calidad y automatización | Pruebas completas, CI/CD, escaneos y observabilidad | Pipeline verde, smoke tests, métricas, alertas y ausencia de fallos críticos |
| 8 | Entrega académica | Documentación, APK/AAB, respaldo, presentación y demostración | Criterio final completo y evidencias organizadas |

## Ceremonias mínimas

- Planeación: seleccionar historias con dependencias resueltas y criterios claros.
- Seguimiento: actualizar tablero, riesgos y decisiones durante el sprint.
- Revisión: demostrar funciones con información real, no simulada.
- Retrospectiva: registrar acciones concretas para el sprint siguiente.
- Cierre: actualizar pruebas, documentación, tablero y errores conocidos.

## Política de alcance

Una historia incompleta regresa al siguiente sprint con sus subtareas pendientes visibles. No se contabiliza como terminada por tener solamente interfaz, datos simulados o una prueba manual parcial.
