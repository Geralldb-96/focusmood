# Mood · FocusMood

Aplicación móvil de bienestar y organización académica para estudiantes universitarios: registro diario de ánimo, energía y concentración, recomendaciones de estudio y bienestar con IA (Gemini), hábitos, temporizador Pomodoro, ejercicios de respiración y resumen semanal.

| Carpeta | Descripción | Stack |
| --- | --- | --- |
| `mobile/` | **App móvil (principal)** | Flutter 3 · Dart 3, Provider, Material 3 |
| `backend/` | API REST | Java 21, Spring Boot 4.1, PostgreSQL, Flyway, JWT |
| `/` (raíz) + `src/` | Prototipo web de diseño (referencia) | React 19, Vite 6 |

## Estructura

```
focusmood/
├── mobile/                 # App Flutter (ver mobile/README.md)
│   ├── lib/core            # cliente HTTP (JWT + refresh), tema, configuración
│   ├── lib/data            # modelos y repositorios (interfaz + implementación)
│   ├── lib/state           # controladores ChangeNotifier
│   ├── lib/ui              # pantallas y widgets
│   └── test/               # pruebas unitarias y de widgets
├── backend/                # API Spring Boot (ver backend/README.md y backend/API.md)
├── docker-compose.yml      # PostgreSQL (+ backend)
├── src/, index.html, ...   # prototipo React; también consume la API
└── vite.config.js          # proxy /api -> :8080 para el prototipo web
```

## Puesta en marcha

1. **Base de datos y backend**

   ```sh
   JWT_SECRET=dev-only-secret-change-me-0123456789abcdef docker compose up -d db
   cd backend
   SPRING_PROFILES_ACTIVE=dev ./mvnw spring-boot:run     # API en http://localhost:8080
   ```

   Las migraciones de Flyway se aplican solas al iniciar. Referencia de rutas en [backend/API.md](backend/API.md).

2. **App Flutter** (requiere Flutter 3.x; para Android, el SDK)

   ```sh
   cd mobile
   flutter pub get
   flutter run -d chrome --web-port 5173                          # en el navegador
   flutter run                                                     # emulador Android (usa 10.0.2.2:8080)
   flutter run --dart-define=API_URL=http://<IP-de-tu-PC>:8080     # teléfono real en la misma red
   flutter test                                                    # pruebas
   ```

3. **APK**

   ```sh
   cd mobile
   flutter build apk --release --dart-define=API_URL=http://<IP-de-tu-PC>:8080
   # build/app/outputs/flutter-apk/app-release.apk
   ```

   El APK queda firmado con la clave de depuración y permite HTTP sin cifrar (solo desarrollo). Para producción: HTTPS, quitar `usesCleartextTraffic` y configurar una firma propia. El APK no se versiona.

## App móvil

Pantallas: bienvenida, registro e inicio de sesión, recuperación de acceso, inicio, registro diario, recomendación e historial, hábitos (crear, editar, eliminar, marcar), Pomodoro y sesiones, bienestar con ejercicios guiados, progreso semanal, perfil, recordatorios, privacidad, ayuda y acerca de.

- Los sliders 0-10 del registro diario se convierten a la escala 1-5 del backend y a un estado de ánimo discreto.
- Los recordatorios son preferencias locales: aún no programan notificaciones del sistema.
- Si la IA no está disponible, el backend responde con una recomendación general por reglas y la app lo indica.
- Pendiente: notificaciones del sistema, exportar datos y que la personalización con IA tenga efecto.

## Backend

Requisitos: JDK 21 y PostgreSQL (o Docker). Maven viene incluido (`mvnw`). Detalles de arquitectura, decisiones y principios SOLID en [backend/README.md](backend/README.md).

### Variables de entorno

| Variable | Obligatoria | Por defecto | Descripción |
| --- | --- | --- | --- |
| `JWT_SECRET` | Sí (fuera de `dev`) | — | Secreto HS256, mínimo 32 caracteres |
| `DB_URL` | No | `jdbc:postgresql://localhost:5432/focusmood` | URL JDBC de PostgreSQL |
| `DB_USER` | No | `focusmood` | Usuario de la base de datos |
| `DB_PASSWORD` | No | vacío | Contraseña de la base de datos |
| `PORT` | No | `8080` | Puerto del servidor |
| `JWT_TTL` | No | `PT15M` | Duración del token de acceso |
| `REFRESH_TTL` | No | `P7D` | Duración de la sesión (refresh token) |
| `RESET_TOKEN_TTL` | No | `PT30M` | Duración del token de recuperación |
| `CORS_ALLOWED_ORIGINS` | No | `localhost` (5173, Capacitor) | Orígenes permitidos por CORS (la app nativa no lo necesita) |
| `GEMINI_API_KEY` | No | vacío | Clave de Gemini; sin ella se usa siempre la recomendación de respaldo |
| `GEMINI_MODEL` | No | `gemini-2.5-flash` | Modelo de Gemini |
| `APP_ZONE` | No | `America/Bogota` | Zona horaria de "hoy" |

> **Seguridad:** nunca subas secretos (`JWT_SECRET`, `GEMINI_API_KEY`, contraseñas) al repositorio. Defínelos solo como variables de entorno.

## Prototipo web (referencia)

El frontend React de la raíz se conserva como referencia del diseño y también está conectado a la API (`npm ci && npm run dev`, requiere Node 22+). Vite reenvía `/api` al backend (`VITE_PROXY_TARGET` lo cambia). La app oficial es la de `mobile/`.

## Contribuir

1. Crea una rama a partir de `main`: `git checkout -b feature/mi-cambio`.
2. Haz commits pequeños y descriptivos.
3. Verifica que `flutter test` (mobile), `./mvnw test` (backend) y, si tocas el prototipo, `npm run build` pasen antes de abrir un pull request.
