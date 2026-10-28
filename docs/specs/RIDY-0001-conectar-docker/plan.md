# RIDY-0001 — Plan

1. **Migrar a pnpm:** `pnpm import` → borrar `package-lock.json` y `node_modules/` → `pnpm install`.
2. **Forzar pnpm:** `packageManager` + `engines.npm` en `package.json`; `.npmrc` con `engine-strict=true`.
3. **Supabase CLI:** `pnpm add -D supabase` (sin build script que aprobar en v2.121+).
4. **Init:** `pnpm supabase init` → `supabase/`. Crear `seed.sql` vacío.
5. **Scripts:** `db:*` en `package.json`.
6. **Git/env:** `.gitignore`, `.env.example`. `.env.local` no se toca (es personal).
7. **Docs:** README con setup y conexión del equipo; anotar la decisión de stack en `docs/constitution.md`.
8. **Verificar:** `pnpm db:start` + `pnpm db:status`; `npm install` debe fallar.

No hay código de dominio → no aplica TDD; la verificación es manual (paso 8).
