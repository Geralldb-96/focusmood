# Gestión del proyecto FocusMood

Esta carpeta reúne los controles de planeación y seguimiento del proyecto. La aplicación móvil conserva Flutter y Dart; el backend planificado utiliza Java 21, Spring Boot, PostgreSQL, Gemini, Docker y Kubernetes.

## Documentos de control

- [Errores y pendientes conocidos](known-issues.md)
- [Tablero FCM-01 a FCM-17](project-board.md)
- [Plan de sprints](sprints.md)
- [Definición de terminado](definition-of-done.md)
- [Registro de decisiones técnicas](technical-decisions.md)

## Línea base validada

Fecha de validación: 8 de noviembre de 2026.

- Rama de trabajo: `develop`.
- Respaldo remoto: etiqueta `backup-before-implementation-2026-11-08`.
- `flutter doctor -v`: sin problemas.
- `flutter analyze`: sin problemas.
- `flutter test`: 9 pruebas aprobadas.
- `flutter build apk --debug`: compilación aprobada.
- APK de línea base: `build/app/outputs/flutter-apk/app-debug.apk`.
- Revisión de secretos rastreados: sin coincidencias en Git.
- Interfaz principal comprobada manualmente en Android 16, API 36.

Los documentos se actualizan en la misma rama que el cambio que describen. Una tarea no se marca como completada sin la evidencia exigida por la definición de terminado.
