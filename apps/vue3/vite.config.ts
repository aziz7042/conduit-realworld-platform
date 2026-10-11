import { URL, fileURLToPath } from 'node:url'

import { defineConfig } from 'vite'
import Vue from '@vitejs/plugin-vue'
import VueRouter from 'unplugin-vue-router/vite'
import AutoImport from 'unplugin-auto-import/vite'
import Components from 'unplugin-vue-components/vite'
import { VueRouterAutoImports, getPascalCaseRouteName } from 'unplugin-vue-router'

export default defineConfig({
  plugins: [
    VueRouter({
      getRouteName: getPascalCaseRouteName,
      dts: false,
    }),
    Vue(),
    Components({ dts: true }),
    AutoImport({
      dts: true,
      vueTemplate: true,
      imports: ['vue', 'pinia', VueRouterAutoImports],
    }),
  ],
  server: {
    host: false,
    open: true,
    proxy: {
      '/api': {
        changeOrigin: true,
        target: 'http://localhost:8081', // '^http:\/\/(localhost|127\.0\.0\.1|api)(:\d+)?',
        rewrite: path => path.replace(/^\/api/, ''),
      },
    },
  },
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
})
