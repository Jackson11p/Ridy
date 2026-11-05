# ATDE-6 — Monorepo pnpm + esqueleto de la app Expo

## Problema

No existen `apps/`, `packages/` ni `pnpm-workspace.yaml`. Sin la app base, ninguna historia móvil, CI (ATDE-12) ni `packages/shared` (ATDE-13) puede empezar, y los scripts `typecheck|lint|test` que citan los agentes no existen.

## Objetivo

`pnpm install` en la raíz deja lista `apps/mobile` (Expo + RN + TS estricto + Expo Router) con los grupos de rutas vacíos, capas de ADR-0001, i18n es/en y el runner del ADR funcionando.

## Criterios de aceptación

1. `pnpm-workspace.yaml` con `apps/*` y `packages/*`.
2. `apps/mobile` arranca en Expo (Android e iOS) con `strict: true`.
3. Grupos `(auth)`, `(parent)`, `(driver)`, `(manage)` en `apps/mobile/app/`, cada uno con una pantalla placeholder.
4. `apps/mobile/src/` según ADR-0001 (`features/`, `components/`, `services/`, `theme/`, `i18n/`).
5. i18n es/en: textos de las pantallas placeholder salen de i18n; idioma del dispositivo, respaldo `es`.
6. `pnpm typecheck`, `pnpm lint`, `pnpm test` existen en la raíz y pasan (al menos un test jest-expo real).
7. Versiones de deps nuevas anotadas en constitución §2 y `docs/contexto/arquitectura.md`, aprobadas por los socios.
8. ADR-0001 pasa a **Aceptado** (PR #2 aprobado y mergeado).

## Fuera de alcance

- Cliente Supabase en la app, TanStack Query, mapas, GPS, push, Sentry (cada uno en su ticket).
- `packages/shared` con contenido (ATDE-13), CI (ATDE-12), `apps/web`.
- Navegación por rol / login real (ATDE-15).

## Supuestos

- Ticket Jira `ATDE-6`; rama y carpeta `ATDE-6-monorepo-expo`; tareas `ATDE-6-Tnn`.
- Versiones: las que fija Expo SDK 58 (`create-expo-app` + `expo install`), no las `latest` sueltas.
- i18n con `i18next` + `react-i18next` + `expo-localization` (lo más usado en Expo; pendiente aprobación).
- Lint con `eslint` + `eslint-config-expo` (config oficial de Expo).
- Las deps Supabase de la raíz se quedan donde están; moverlas a `apps/mobile` va con el ticket del cliente.
