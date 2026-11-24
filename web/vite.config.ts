import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';

// Mismos puertos de siempre: sitio y panel en 5500 (CORS de la API ya lo permite), app Homiz en 5600, API en 3000.
export default defineConfig({
  plugins: [react(), tailwindcss()],
  // /api pasa a la API del puerto 3000 (útil con VITE_API_URL=/api/v1: mismo origen, sin CORS)
  // allowedHosts: los puertos reenviados de VS Code (https://abc-5500.usw2.devtunnels.ms) y los túneles públicos
  // de Cloudflare (https://xxx.trycloudflare.com, que llaman a la API por /api de este mismo servidor)
  server: { host: true, port: 5500, strictPort: true, allowedHosts: ['.devtunnels.ms', '.trycloudflare.com'], proxy: { '/api': 'http://localhost:3000' } },
  preview: { host: true, port: 5500, strictPort: true, allowedHosts: ['.devtunnels.ms', '.trycloudflare.com'] },
  // Dos páginas: el sitio público (index.html) y el panel (admin/index.html), cada una con su CSS
  build: {
    rollupOptions: {
      input: { sitio: 'index.html', panel: 'admin/index.html', acceso: 'admin/login.html' },
    },
  },
});
