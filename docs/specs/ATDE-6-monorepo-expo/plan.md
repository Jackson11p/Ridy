# ATDE-6 — Plan

## Workspace

- `pnpm-workspace.yaml` raíz: `apps/*`, `packages/*`. `packages/` arranca vacío (`.gitkeep`).
- Raíz conserva scripts `db:*`; agrega `typecheck`, `lint`, `test` que delegan con `pnpm -r --if-present <script>`.
- `.npmrc` mantiene el bloqueo de npm; se agrega `node-linker=hoisted` solo si Metro no resuelve con el layout por defecto de pnpm (verificar al arrancar).

## App `apps/mobile`

- Generada con `pnpm create expo-app apps/mobile --template` (TypeScript + Expo Router) para heredar versiones compatibles con SDK 58; se borra el contenido demo del template.
- `tsconfig.json` extiende `expo/tsconfig.base` con `strict: true`; alias `@/*` → `src/*`.
- `app/_layout.tsx`: Stack raíz que inicializa i18n.
- `app/index.tsx`: redirige a `(auth)` (sin lógica de rol; llega con ATDE-15).
- `app/(auth|parent|driver|manage)/_layout.tsx` + `index.tsx`: placeholder con un título traducido.

## Capas (ADR-0001)

- `src/features/` vacío con `.gitkeep` (YAGNI: ningún feature aún).
- `src/components/screen-title.tsx`: único componente genérico, recibe texto por props (lo usan los placeholders).
- `src/services/` vacío (`.gitkeep`): el cliente Supabase llega con su ticket.
- `src/theme/colors.ts`: tokens mínimos usados por `screen-title`.
- `src/i18n/index.ts` + `locales/es.json`, `locales/en.json`: init de i18next con idioma de `expo-localization`, respaldo `es`.

## Runner y calidad

- `jest-expo` preset en `apps/mobile/package.json`; `@testing-library/react-native`.
- Primer test: `screen-title.test.tsx` (renderiza texto) y `i18n/index.test.ts` (respaldo a `es` con idioma no soportado).
- Scripts app: `typecheck` = `tsc --noEmit`, `lint` = `expo lint`, `test` = `jest`.

## Docs

- Constitución §2: versiones aprobadas. `docs/contexto/arquitectura.md` y `flujo-de-trabajo.md`: quitar "no existe" de apps/scripts/runner.
- ADR-0001 y `decisiones.md`: Propuesto → Aceptado.

## Verificación

- `pnpm install` limpio, `pnpm typecheck && pnpm lint && pnpm test` en verde.
- `pnpm --filter mobile start` abre Metro sin errores (Android/iOS lo prueba un socio con Expo Go).
