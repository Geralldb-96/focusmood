import { defineConfig } from 'vite';

// En desarrollo, /api se reenvía al backend para evitar CORS. Cambia el destino con VITE_PROXY_TARGET.
export default defineConfig({
  server: {
    proxy: {
      '/api': process.env.VITE_PROXY_TARGET || 'http://localhost:8080',
    },
  },
});
