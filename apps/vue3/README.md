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

## Upstream provenance

This client derives from Niyaco's MIT-licensed [`vue3-realworld-app`](https://github.com/niyaco/vue3-realworld-app), which implements the [RealWorld frontend specification](https://github.com/gothinkster/realworld). Niyaco is the upstream maintainer, not the maintainer of this portfolio repository. The university team adapted and integrated the client with its backend and project workflow. The upstream MIT license remains in force.
