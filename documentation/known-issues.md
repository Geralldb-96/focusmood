# Errores y pendientes conocidos

Registro inicial basado en el análisis, las pruebas automatizadas y la prueba manual del 8 de noviembre de 2026.

| ID | Prioridad | Área | Hallazgo | Estado | Trabajo relacionado |
| --- | --- | --- | --- | --- | --- |
| ERR-001 | Alta | Registro | Falta el campo para confirmar la contraseña exigido por FCM-01. | Abierto | 6.5, 6.9 |
| ERR-002 | Media | Registro | El aviso de términos también menciona la contraseña aunque esta ya sea válida. | Abierto | 6.16 |
| ERR-003 | Alta | Inicio | La fecha visible es demostrativa y no corresponde al día actual. | Abierto | 3.14, 3.18 |
| ERR-004 | Alta | Registro diario | Energía y concentración usan una escala de 1 a 10; el modelo definido requiere 1 a 5. | Abierto | 5.28, 5.29, 10.2, 10.3 |
| ERR-005 | Crítica | Autenticación | Registro, inicio, recuperación y cierre de sesión son simulaciones locales, sin servidor ni JWT. | Abierto | FCM-01, FCM-02, FCM-03, FCM-17 |
| ERR-006 | Crítica | IA | Las recomendaciones son demostrativas y no provienen de Gemini. | Abierto | FCM-07 |
| ERR-007 | Alta | Datos | Historiales, rachas, métricas, progreso y notificaciones contienen información ilustrativa. | Abierto | FCM-09, FCM-11, FCM-15, FCM-16 |
| ERR-008 | Crítica | Arquitectura | Aún no existen backend Spring Boot, PostgreSQL, migraciones, OpenAPI ni HTTPS. | Abierto | 4, 5, 18 |
| ERR-009 | Alta | Android | El manifiesto de release no declara todavía el permiso `INTERNET`. | Abierto | 3.23 |
| ERR-010 | Alta | Distribución | La compilación release no tiene firma de producción ni AAB validado. | Abierto | 3.25, 3.26 |
| ERR-011 | Media | Entorno | El equipo tiene Flutter 3.47.3 y Dart 3.13.3, mientras el repositorio documenta 3.47.9 y 3.13.7. | Abierto | 1.5, 25.11 |
| ERR-012 | Media | Java | Java del sistema es 27 y el JBR de Flutter es 25; el backend debe fijarse explícitamente en JDK 21. | Abierto | 4.1 |
| ERR-013 | Media | Android | Gradle mostró advertencias de acceso nativo y de versión XML del SDK, aunque el APK se compiló. | En observación | 22.25, 22.31 |
| ERR-014 | Alta | Recordatorios | Los interruptores guardan preferencias, pero no programan notificaciones Android. | Abierto | FCM-16 |
| ERR-015 | Alta | Persistencia | La información se guarda en `shared_preferences`; PostgreSQL aún no es la fuente principal. | Abierto | 5, 13.18 |
| ERR-016 | Media | Accesibilidad | Falta validar la aplicación con lector de pantalla, escalado de texto y navegación accesible. | Abierto | 22 |

## Reglas de mantenimiento

1. Asignar un identificador nuevo sin reutilizar números.
2. Registrar pasos de reproducción cuando exista un fallo reproducible.
3. Cambiar a `Resuelto` solamente después de una prueba automatizada o manual verificable.
4. Relacionar la corrección con una tarea, historia FCM o decisión técnica.
5. No borrar hallazgos resueltos; conservarlos como historial.
