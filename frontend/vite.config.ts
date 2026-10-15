import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import fs from 'fs';
import path from 'path';

// Read Rails secret key base for HMAC signing
const railsRoot = path.resolve(__dirname, '..');
const secretKeyFile = path.join(railsRoot, '.secret_key_base');

let secret = '';
try {
  secret = fs.readFileSync(secretKeyFile, 'utf8').trim();
} catch (e) {
  // Fallback in development
  console.warn('Secret key base file not found, using fallback');
}

export default defineConfig(({ command, mode }) => {
  const isProduction = mode === 'production';

  return {
    plugins: [react()],
    server: {
      host: 'localhost',
      port: 5173,
      hmr: {
        clientPort: 5173,
      },
      proxy: {
        // Proxy API requests to Rails backend
        '/api': {
          target: 'http://localhost:3000',
          changeOrigin: true,
          secure: false,
          ws: true,
        },
        // Proxy Devise authentication requests
        '/users': {
          target: 'http://localhost:3000',
          changeOrigin: true,
          secure: false,
        },
        // Proxy health checks
        '/up': {
          target: 'http://localhost:3000',
          changeOrigin: true,
          secure: false,
        },
      },
    },
    resolve: {
      alias: {
        '@': path.resolve(__dirname, './src'),
      },
    },
    build: {
      outDir: '../public/vite',
      emptyOutDir: true,
      rollupOptions: {
        input: {
          main: path.resolve(__dirname, 'index.html'),
        },
      },
      manifest: true,
      define: {
        'process.env.NODE_ENV': isProduction ? '"production"' : '"development"',
      },
    },
    define: {
      global: 'globalThis',
    },
  };
});