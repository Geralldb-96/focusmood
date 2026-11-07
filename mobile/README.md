# Mood · App móvil (Flutter)

Cliente Flutter de FocusMood. Consume la API de `../backend` (login con renovación de token, hábitos, registro diario,
recomendaciones con IA, Pomodoro, bienestar y progreso semanal).

## Estructura (`lib/`)
- `core/` cliente HTTP (JWT + refresh), tema, configuración, almacén seguro de tokens.
- `data/` modelos y repositorios (interfaz + implementación por módulo).
- `state/` controladores `ChangeNotifier` (Provider) que dependen de las interfaces de repositorio.
- `ui/` pantallas y widgets.

## Ejecutar
Backend arriba (`docker compose up -d db` + `./mvnw spring-boot:run` con perfil `dev`), luego:

```sh
flutter pub get
flutter run -d chrome --web-port 5173                         # web (CORS permitido para :5173)
flutter run                                                    # emulador Android: usa http://10.0.2.2:8080
flutter run --dart-define=API_URL=http://<IP-de-tu-PC>:8080    # teléfono real en la misma red
```

## APK
```sh
flutter build apk --release --dart-define=API_URL=http://<IP-de-tu-PC>:8080
# -> build/app/outputs/flutter-apk/app-release.apk
```
El manifest permite tráfico HTTP sin cifrar (`usesCleartextTraffic`) solo para desarrollo; en producción usa HTTPS y quítalo.
El APK se firma con la clave de depuración; para publicar hay que configurar una firma propia.

## Pruebas
`flutter test` (cliente HTTP, mapeos, temporizador y flujo de login).

## Pendiente
Recordatorios del sistema (hoy son preferencias locales), exportar datos y personalización con IA.
