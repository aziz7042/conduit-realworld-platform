declare module 'vue-router/auto' {
  export * from 'vue-router'

  import type { RouteRecordRaw, Router, RouterOptions } from 'vue-router'

  type AutoRouterOptions = Omit<RouterOptions, 'routes'> & {
    routes?: RouteRecordRaw[]
    extendRoutes?: (routes: RouteRecordRaw[]) => RouteRecordRaw[]
  }

  export function createRouter(options: AutoRouterOptions): Router
}
