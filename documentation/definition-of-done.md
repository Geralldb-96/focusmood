# Definición de terminado

Una historia se marca como `Completada` solo cuando cumple todos los criterios aplicables.

## Funcionalidad

- Cumple los criterios de aceptación de la historia FCM.
- No depende de usuarios, métricas, historiales ni recomendaciones demostrativas.
- Maneja carga, ausencia de información, error y reintento.
- Funciona en tema claro y oscuro y en los tamaños Android seleccionados.

## Flutter

- La vista, el estado, el repositorio y los servicios están separados según la arquitectura acordada.
- Las rutas privadas verifican una sesión válida.
- Los tokens se guardan en almacenamiento seguro, nunca en `shared_preferences`.
- No existen errores silenciosos que oculten fallos relevantes.
- `dart format`, `flutter analyze` y `flutter test` finalizan correctamente.

## Backend y API

- El endpoint está versionado bajo `/api/v1` y documentado en OpenAPI.
- Las entradas tienen validación y los errores usan el formato común.
- Autenticación, autorización y propiedad del recurso están comprobadas.
- No se registran contraseñas, tokens ni datos sensibles.
- Las pruebas unitarias, de controlador e integración correspondientes pasan.

## Base de datos

- El cambio tiene una migración Flyway reversible mediante restauración o migración correctiva documentada.
- Claves, restricciones, índices y comportamiento de eliminación están definidos.
- Fechas del servidor usan UTC y PostgreSQL `TIMESTAMPTZ` cuando corresponde.
- La migración se valida con PostgreSQL real mediante Testcontainers o el entorno controlado.

## Inteligencia artificial

- La clave de Gemini permanece únicamente en el backend.
- El prompt está versionado y no envía nombre, correo ni identificadores internos.
- La respuesta estructurada se valida y rechaza diagnósticos, medicamentos y contenido ofensivo.
- Existen timeout, límite de uso, reintentos controlados y recomendación segura de respaldo.

## Infraestructura y seguridad

- La imagen Docker se ejecuta como usuario no root y pasa su health check.
- Configuración y secretos se proporcionan desde el ambiente, no desde Git ni la imagen.
- Los manifiestos Kubernetes incluyen probes, recursos y configuración por ambiente cuando apliquen.
- Las dependencias y la imagen no tienen vulnerabilidades críticas conocidas sin una excepción aprobada.

## Evidencia y documentación

- El cambio incluye pruebas automáticas proporcionales al riesgo y una prueba manual cuando corresponda.
- Se actualizan README, OpenAPI, diagramas o manuales afectados.
- El tablero, el registro de errores y las decisiones técnicas reflejan el resultado.
- La evidencia indica comando, ambiente, fecha y resultado.
- El repositorio queda sin secretos y sin archivos accidentales.
