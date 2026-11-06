# FocusMood · Flutter y Dart

Aplicación móvil de bienestar académico basada en las capturas del diseño Mood. Implementación en **Flutter y Dart**, con tema **oscuro por defecto**, selector de tema claro/oscuro y proyecto Android nativo. Esta versión sustituye el frontend React anterior.

## Desarrollo

Validado con Flutter **3.47.9**, Dart **3.13.7** y JDK **21**. Las dependencias están fijadas en `pubspec.lock`.

```sh
flutter pub get
flutter run
```

Elige un teléfono Android, un emulador o Chrome entre los dispositivos disponibles. Para web:

```sh
flutter run -d chrome
flutter build web --no-web-resources-cdn
```

## Entorno en la nube y emulador

En este entorno las herramientas están instaladas en `/workspace/toolchains/`:

```sh
cd /workspace/focusmood
source tool/env.sh
bash tool/start_emulator.sh
adb -e shell getprop sys.boot_completed
flutter devices
flutter run -d emulator-5554
```

En VS Code, instala las extensiones recomendadas de Flutter/Dart y selecciona **Mood · Android emulator** en Ejecutar y depurar después de arrancar el dispositivo.

`sys.boot_completed` debe devolver `1` antes de instalar o ejecutar la aplicación. El emulador se llama **focusmood**, usa Android **15 / API 35** y un dispositivo Pixel 6. El script reutiliza un emulador existente. Arranca sin ventana por defecto; con una sesión gráfica disponible se puede iniciar usando `MOOD_EMULATOR_WINDOW=1 bash tool/start_emulator.sh` cuando no haya otro emulador en marcha.

Este entorno no dispone de `/dev/kvm`: usa emulación por software, por lo que el primer arranque y las interacciones pueden tardar varios minutos. Un proceso de emulador no se conserva al restaurar una nueva máquina; vuelve a ejecutar el script de arranque. No crees otro checkout ni un worktree para iniciar la app.

`tool/env.sh` configura el SDK, Flutter, Chromium y la ruta del proxy de la plataforma para Java/Gradle. Conserva la verificación TLS. En tu computadora puedes usar tus instalaciones de Flutter y Android Studio directamente, sin este archivo específico de la nube.

## APK de depuración

Con JDK 21 y Android SDK instalados:

```sh
flutter build apk --debug
adb -e install -r build/app/outputs/flutter-apk/app-debug.apk
adb -e shell am start -n com.focusmood.focusmood/.MainActivity
```

El APK queda en `build/app/outputs/flutter-apk/app-debug.apk`. Los binarios y cachés no se versionan. Para distribución pública se necesitan firma propia y configuración de release.

## Validación

```sh
flutter analyze
flutter test
```

Las pruebas verifican conservación del esquema de datos anterior, guardado de hábitos, selector de tema, pausa/reanudación/finalización del temporizador, borrado de información y disposición de pantallas de 320 y 390 px en ambos temas.

## Funcionalidad

- Bienvenida, registro e inicio de sesión de demostración y recuperación de acceso.
- Registro diario de ánimo, energía y concentración; contexto académico.
- Recomendación ilustrativa, valoración, guardado e historial.
- Creación, edición, eliminación y cumplimiento de hábitos.
- Pomodoro con duración personalizada, pausa/reanudación y sesiones guardadas.
- Catálogo de bienestar, ejercicios guiados y progreso semanal ilustrativo.
- Notificaciones de ejemplo, preferencias de recordatorios, perfil y privacidad.
- Tema claro/oscuro persistente y exportación JSON al portapapeles.

## Datos y arquitectura

- `lib/main.dart`: aplicación Flutter, rutas, pantallas y controles reutilizables.
- `lib/mood_store.dart`: modelos, estado, persistencia y temporizador.
- `lib/theme.dart`: paleta Mood y temas Material.
- `lib/legacy_storage*.dart`: lectura de las claves anteriores en Flutter Web.
- `test/`: pruebas de estado y widgets.
- `android/`: proyecto Android Flutter; `web/`: soporte de navegador.

Los datos se guardan con `shared_preferences`. Flutter Web puede leer las claves `mood-*` anteriores de localStorage **si se usa el mismo origen y navegador**. Cambiar de dominio/puerto o pasar del navegador a Android usa otro almacenamiento; exporta una copia antes. No se guardan contraseñas.

El temporizador se mantiene entre pantallas y recalcula al volver al primer plano. No es un servicio de Android en segundo plano; el sistema puede cerrar la app.

## Integraciones pendientes

El acceso es una **simulación local**, no autenticación real: no uses contraseñas reales. Google, envío de correos, IA Gemini, audio y avisos automáticos requieren servicios adicionales. Los switches de recordatorios guardan preferencias; no programan avisos. El temporizador no silencia las notificaciones del sistema. Algunas métricas e historiales son datos de ejemplo identificados en la interfaz.

El backend de Java/Spring Boot y PostgreSQL descrito en la guía aún no está implementado. La app deberá comunicarse con él mediante una API REST. Las credenciales de Gemini y la conexión a la base de datos deben permanecer en ese backend.
