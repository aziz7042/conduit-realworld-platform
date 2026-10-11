import { defineConfig } from 'cypress'

// Cypress Konfigurationsdatei für End-to-End Tests
export default defineConfig({
  e2e: {
    // Basis-URL für alle Tests, z. B. cy.visit('/login') wird zu http://localhost:5173/login
    baseUrl: 'http://localhost:5173',

    // Legt das Support-File fest, in dem globale Befehle oder Hooks definiert werden
    supportFile: 'cypress/support/e2e.ts',
  },
})
