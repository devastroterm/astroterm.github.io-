import { defineConfig } from 'vite'
import { resolve } from 'path'

export default defineConfig({
  base: '/astroterm.github.io-/',
  build: {
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'),
        privacy: resolve(__dirname, 'privacy.html'),
        terms: resolve(__dirname, 'terms.html'),
        support: resolve(__dirname, 'support.html'),
      },
    },
  },
})
