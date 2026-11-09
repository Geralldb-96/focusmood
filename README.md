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

### Requisitos

| Herramienta | Versión | Para qué |
| --- | --- | --- |
| JDK | 21 | Backend (Maven viene incluido: `mvnw`) |
| Docker Desktop | reciente | PostgreSQL (o el stack completo) |
| Flutter | 3.x | App móvil (`mobile/`) |
| Android Studio / SDK | opcional | Emulador o APK |
| Node.js | 22+ | Solo el prototipo web de la raíz |

### 1. Configuración (una sola vez)

Crea un archivo `.env` en la raíz (está en `.gitignore`; Docker Compose lo lee solo):

```env
JWT_SECRET=un-secreto-de-al-menos-32-caracteres-cambialo
# Opcionales
# DB_PASSWORD=focusmood
# GEMINI_API_KEY=tu-clave        # sin clave, las recomendaciones usan el respaldo por reglas
```

> `docker-compose.yml` exige `JWT_SECRET` aunque solo levantes la base de datos; si falta, `docker compose` falla con "Define JWT_SECRET".

### 2. Levantar el backend

Elige **una** opción.

**Opción A · Base de datos en Docker + backend con Maven** (recomendada para desarrollar)

```sh
docker compose up -d db          # PostgreSQL 17 en localhost:5432
cd backend
```

Linux/macOS/Git Bash:

```sh
SPRING_PROFILES_ACTIVE=dev ./mvnw spring-boot:run
```

Windows PowerShell:

```powershell
$env:SPRING_PROFILES_ACTIVE = "dev"
.\mvnw.cmd spring-boot:run
```

El perfil `dev` trae un `JWT_SECRET` de desarrollo y la contraseña `focusmood` de la base, que coincide con la de `docker-compose.yml`. Sin ese perfil tendrás que definir `JWT_SECRET` y `DB_PASSWORD` tú mismo.

**Opción B · Todo en Docker** (base de datos + backend)

```sh
docker compose up -d --build
```

Compila el backend dentro de la imagen y lo publica en `http://localhost:8080`. Lee `JWT_SECRET` y `GEMINI_API_KEY` del `.env`.

**Comprobar que arrancó.** Las migraciones de Flyway se aplican solas. El proyecto no incluye Actuator, así que no hay `/actuator/health`; prueba con un endpoint protegido, que debe responder `401`:

```sh
curl -i http://localhost:8080/api/v1/study-techniques
```

Referencia de rutas en [backend/API.md](backend/API.md).

### 3. Levantar la app Flutter

Con el backend ya corriendo:

```sh
cd mobile
flutter pub get
flutter run -d chrome --web-port 5173                          # navegador (CORS ya permite :5173)
flutter run                                                     # emulador Android: usa http://10.0.2.2:8080
flutter run --dart-define=API_URL=http://<IP-de-tu-PC>:8080     # teléfono real en la misma red
flutter test                                                    # pruebas
```

- `API_URL` apunta la app a otro backend. En el emulador Android, `10.0.2.2` es el `localhost` de tu PC.
- Para un teléfono real, el PC y el teléfono deben estar en la misma red y el firewall debe permitir el puerto 8080. Averigua tu IP con `ipconfig` (Windows) o `ip addr` / `ifconfig`.

### 4. Generar el APK

```sh
cd mobile
flutter build apk --release --dart-define=API_URL=http://<IP-de-tu-PC>:8080
# -> build/app/outputs/flutter-apk/app-release.apk
```

El APK queda firmado con la clave de depuración y permite HTTP sin cifrar (solo desarrollo). Para producción: HTTPS, quitar `usesCleartextTraffic` y configurar una firma propia. El APK no se versiona.

### 5. Prototipo web (opcional)

```sh
npm ci
npm run dev        # http://localhost:5173, reenvía /api -> :8080
```

Si el backend corre en otra dirección: `VITE_PROXY_TARGET=http://host:puerto npm run dev`. No lo uses a la vez que `flutter run -d chrome --web-port 5173`: ambos usan el puerto 5173.

### 6. Detener y reiniciar

```sh
docker compose down              # detiene los contenedores (conserva los datos)
docker compose down -v           # además BORRA la base de datos
```

### Problemas frecuentes

| Síntoma | Causa y solución |
| --- | --- |
| `Define JWT_SECRET (minimo 32 caracteres)` al usar Docker | Falta `JWT_SECRET` en `.env` o en el entorno |
| `Could not resolve placeholder 'JWT_SECRET'` en Maven | Arrancaste sin el perfil `dev`: actívalo o define `JWT_SECRET` |
| `password authentication failed` / `Connection refused` | La base no está arriba (`docker compose ps`) o `DB_PASSWORD` no coincide con la del contenedor. Si cambiaste la contraseña, `docker compose down -v` y vuelve a levantar |
| `Port 5432` o `8080 already in use` | Otro PostgreSQL o proceso usa el puerto; ciérralo o cambia `PORT` / el mapeo en `docker-compose.yml` |
| La app en el emulador no conecta | Usa `10.0.2.2`, no `localhost`; verifica que el backend responda en `:8080` |
| La app en el teléfono no conecta | Revisa `API_URL`, la IP, que estén en la misma red y el firewall |
| Error de CORS en el navegador | Sirve la app en `http://localhost:5173` o añade tu origen a `CORS_ALLOWED_ORIGINS` |
| Las recomendaciones dicen "respaldo" / `reglas-locales` | No hay `GEMINI_API_KEY` (o Gemini falló): es el comportamiento esperado |

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

El frontend React de la raíz se conserva como referencia del diseño y también está conectado a la API (ver [paso 5](#5-prototipo-web-opcional)). La app oficial es la de `mobile/`.

## Contribuir

1. Crea una rama a partir de `main`: `git checkout -b feature/mi-cambio`.
2. Haz commits pequeños y descriptivos.
3. Verifica que `flutter test` (mobile), `./mvnw test` (backend) y, si tocas el prototipo, `npm run build` pasen antes de abrir un pull request.
