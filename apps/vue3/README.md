# Conduit web client · Vue 3

The Vue 3 and TypeScript client for this repository's RealWorld platform.

## Stack

- Vue 3 and TypeScript
- Vite
- Pinia
- Vue Router
- Axios
- Cypress end-to-end tests

## Run locally

```bash
npm install
npm run dev
npm run typecheck
npm run build
npm run test:e2e
```

The web client expects the repository's Conduit API to be available locally.

## Credits

This client derives from Niyaco's MIT-licensed [`vue3-realworld-app`](https://github.com/niyaco/vue3-realworld-app), which implements the [RealWorld frontend specification](https://github.com/gothinkster/realworld). Niyaco maintains the upstream project; the university team adapted the client and connected it to this project's backend and workflow. The upstream MIT license remains in force.
