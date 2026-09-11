import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    // Fixed port so the Firebase Auth "Authorised domains" entry and any
    // bookmarked console URL keep working. `strictPort` makes a clash fail
    // loudly instead of silently moving to 4006 — a moved dev server looks
    // like a broken sign-in, because the OAuth redirect no longer matches.
    port: 4005,
    strictPort: true,
  },
  preview: {
    port: 4005,
    strictPort: true,
  },
})
