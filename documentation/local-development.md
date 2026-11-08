# Ejecución local de FocusMood

Esta guía describe cómo preparar y ejecutar el proyecto desde la rama `develop`.

## Estado actual

| Componente | Estado |
| --- | --- |
| Aplicación Flutter | Disponible |
| Backend Spring Boot | Pendiente de implementación |
| PostgreSQL | Pendiente de implementación |
| Gemini | Pendiente de integración |
| Docker Compose | Pendiente de implementación |
| Kubernetes | Pendiente de implementación |

Actualmente puede ejecutarse y probarse la aplicación móvil. Esta guía se actualizará cuando los demás componentes estén disponibles.

## Requisitos

- Git
- Visual Studio Code
- Flutter y Dart
- Android Studio o Android SDK
- Un emulador o dispositivo Android
- Java 21 para el futuro backend
- Docker Desktop para el futuro entorno completo
- Una clave de Gemini para la futura integración de IA

Verifica Flutter:

```cmd
flutter doctor -v
flutter devices
```

## Preparación inicial

Clona el repositorio y cambia a la rama de desarrollo:

```cmd
git clone https://github.com/Geralldb-96/focusmood.git
cd focusmood
git switch develop
```

Crea el archivo local de configuración:

```cmd
copy .env.example .env
```

Completa `.env` con valores locales. Nunca publiques ese archivo.

## Ejecutar Flutter

Desde la raíz:

```cmd
cd mobile
flutter pub get
flutter analyze
flutter test
flutter devices
```

Para ejecutar en el emulador Android:

```cmd
flutter run -d emulator-5554
```

Para ejecutar en Chrome:

```cmd
flutter run -d chrome
```

También puede utilizarse la configuración `Mood · Android emulator` de VS Code.

## Compilar el APK

```cmd
cd mobile
flutter build apk --debug
```

El resultado queda en:

```text
mobile/build/app/outputs/flutter-apk/app-debug.apk
```

## Backend

El backend todavía no está implementado. Cuando se cree el proyecto Spring Boot, el comando esperado será:

```cmd
cd backend
mvnw.cmd spring-boot:run
```

No se debe considerar funcional hasta que Java 21, PostgreSQL, Flyway y las pruebas de integración estén configurados.

## Docker Compose

El archivo `compose.yaml` todavía no está implementado. Cuando esté disponible, el entorno completo se iniciará desde la raíz con:

```cmd
docker compose up --build
```

Y se detendrá con:

```cmd
docker compose down
```

No se debe usar `docker compose down -v` sin confirmar que puede eliminarse la información local.

## Direcciones previstas

```text
API:        http://localhost:8080/api/v1
Health:     http://localhost:8080/actuator/health
Swagger:    http://localhost:8080/swagger-ui.html
PostgreSQL: localhost:5432
```

Estas direcciones entrarán en funcionamiento después de implementar el backend.

En el emulador Android, Flutter accederá al servidor local mediante:

```text
http://10.0.2.2:8080/api/v1
```

## Problemas frecuentes

### Flutter espera un bloqueo

Si aparece:

```text
Waiting for another flutter command to release the startup lock
```

Cierra cualquier proceso `flutter run` que siga activo y vuelve a ejecutar el comando.

### El emulador no aparece

```cmd
adb devices
flutter devices
```

El emulador debe estar completamente iniciado antes de ejecutar Flutter.

### Dependencias desactualizadas

```cmd
flutter pub outdated
```

No actualices dependencias automáticamente sin ejecutar nuevamente análisis, pruebas y compilación.

## Validación antes de subir cambios

```cmd
cd mobile
flutter analyze
flutter test
flutter build apk --debug
```

Desde la raíz:

```cmd
git diff --check
git status
```

## Seguridad

Nunca publiques:

- `.env`
- Claves de Gemini
- Contraseñas
- Secretos JWT
- Certificados
- Llaves de firma
- `google-services.json`