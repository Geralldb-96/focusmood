# Mood · Frontend móvil

Interfaz de bienestar académico creada con React, Vite y Lucide a partir de las capturas del diseño proporcionadas.

## Desarrollo

Requisitos: Node.js 22 o superior y npm.

```sh
npm ci
npm run dev
```

```sh
npm run build
npm run preview
```

Incluye bienvenida, registro e inicio de sesión de demostración, recuperación de acceso, registro emocional, recomendación ilustrativa y su historial, hábitos editables, temporizador Pomodoro, sesiones, ejercicios de bienestar, progreso, notificaciones, recordatorios, perfil, privacidad y cierre de sesión.

Los datos se guardan en localStorage de este navegador. El perfil y las estadísticas iniciales son ejemplos; las sesiones comienzan vacías. Puedes exportar o borrar datos en Perfil → Privacidad y datos.

No hay backend: el inicio de sesión es una simulación local, no autentica usuarios. No uses contraseñas reales. Google, recuperación por email, recomendaciones generadas por IA, audio y avisos automáticos requieren integraciones adicionales. El temporizador no silencia las notificaciones del dispositivo. Las preferencias de recordatorios se guardan localmente.

El diseño se adapta al ancho del teléfono. En escritorio se presenta dentro de un marco móvil. La aplicación usa una tipografía de sistema como respaldo si Google Fonts no está disponible.
