# Tablero de historias FCM

Estados permitidos: `Pendiente`, `En curso`, `En revisión`, `Completada` y `Bloqueada`.

| Historia | Alcance | Prioridad | Sprint | Estado inicial | Evidencia actual |
| --- | --- | --- | --- | --- | --- |
| FCM-01 | Registro de usuario | Alta | 1 | En curso | Pantalla y validaciones locales; falta confirmación de contraseña y backend. |
| FCM-02 | Inicio de sesión | Alta | 1 | En curso | Flujo demostrativo local; falta JWT y almacenamiento seguro. |
| FCM-03 | Recuperación de contraseña | Alta | 1 | En curso | Pantalla demostrativa; falta correo y token real. |
| FCM-04 | Perfil de usuario | Media | 1 | En curso | Interfaz local disponible; falta API y autorización. |
| FCM-05 | Registro diario | Alta | 2 | En curso | Formulario local probado; falta persistencia remota. |
| FCM-06 | Contexto académico | Alta | 2 | En curso | Selección local disponible; falta validación y API. |
| FCM-07 | Recomendación personalizada | Alta | 2 | En curso | Interfaz demostrativa; falta integración segura con Gemini. |
| FCM-08 | Valoración de recomendación | Media | 2 | En curso | Controles locales disponibles; falta persistencia e idempotencia. |
| FCM-09 | Historial de recomendaciones | Media | 2 | En curso | Vista demostrativa; falta información real y paginación. |
| FCM-10 | Gestión de hábitos | Alta | 3 | En curso | Crear, editar y activar funciona localmente. |
| FCM-11 | Cumplimiento de hábitos | Alta | 3 | En curso | Marcación y progreso locales; falta sincronización y rachas reales. |
| FCM-12 | Temporizador Pomodoro | Alta | 3 | En curso | Inicio, pausa, reanudación y finalización probados. |
| FCM-13 | Registro de sesiones | Media | 3 | En curso | Sesiones locales; falta API y validación en servidor. |
| FCM-14 | Actividades de bienestar | Media | 4 | En curso | Catálogo e instrucciones demostrativas; falta PostgreSQL. |
| FCM-15 | Progreso semanal | Media | 4 | En curso | Pantalla ilustrativa; faltan consultas y métricas reales. |
| FCM-16 | Recordatorios y notificaciones | Alta | 4 | En curso | Preferencias locales; falta programación Android. |
| FCM-17 | Cierre de sesión | Alta | 1 | En curso | Regreso a bienvenida probado; falta revocar refresh token. |

## Flujo de una historia

1. `Pendiente`: alcance y dependencias identificados.
2. `En curso`: existe trabajo activo en una rama o cambio controlado.
3. `En revisión`: código, migración, contrato y pruebas están listos para verificación.
4. `Completada`: cumple todos los criterios aplicables de `definition-of-done.md`.
5. `Bloqueada`: existe una dependencia externa documentada con responsable y siguiente acción.
