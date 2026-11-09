# ATDE-12 — Plan

## Módulos

### 1. Workflow `.github/workflows/ci.yml`
- Disparador: `pull_request` a `main`.
- `permissions: contents: read` en todo el workflow: el token no puede escribir nada.
- 5 jobs en paralelo sobre `ubuntu-latest`, cada uno con el mismo arranque:
  `checkout` → `pnpm/action-setup` (versión desde `packageManager`) → `setup-node` Node 22 con caché pnpm → `pnpm install --frozen-lockfile`.
- `typecheck`: `pnpm typecheck` (script raíz existente).
- `lint`: `pnpm lint` (script raíz existente).
- `test`: `pnpm test` (jest-expo, sin Docker).
- `test-rls`: `pnpm db:start` (Docker ya viene en el runner) → `pnpm test:db` (pgTAP de `supabase/tests/`). Usa las claves demo locales del CLI; no hay secretos.
- `build`: `expo export --platform android` en `apps/mobile` a `runner.temp`: prueba que el bundle compila sin toolchain nativo ni EAS.
- Nombres de job estables (`typecheck`, `lint`, `test`, `test-rls`, `build`): son los checks que exigirá la protección de rama.

### 2. Protección de rama (manual, dueño del repo)
- Tras el primer run del CI en un PR, activar en `main`: checks requeridos = los 5 jobs, 1 aprobación, revisión de CODEOWNERS, sin push directo.
- Se documenta el comando `gh api` en `docs/contexto/flujo-de-trabajo.md`.

### 3. Docs
- `docs/contexto/flujo-de-trabajo.md`: sección CI pasa de [PLAN] a [IMPL], qué corre cada job y cómo reproducirlo local; paso 9 (PR) enlaza la protección de rama.

## Riesgos
- Tipos de rutas (`.expo/types`, `expo-env.d.ts`) no están en git: verificar typecheck en checkout limpio.
- `supabase start` baja imágenes (~2–3 min): aceptable; optimizar si molesta.
- Protección de rama sin aplicar hasta que el dueño corra el comando: queda anotado en el resumen y en Jira.
