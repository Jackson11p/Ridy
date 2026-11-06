# ATDE-7 — Plan

## Módulos

### 1. Script raíz `test:db`
- `package.json` raíz: `"test:db": "supabase test db"`. Usa el CLI de `devDependencies`, no el global.
- `supabase test db` busca `supabase/tests/**/*.sql` y los corre con `pg_prove` dentro del contenedor de BD local. Requiere `pnpm db:start`.
- `pnpm test` queda igual: solo JS. Separados porque `test:db` necesita Docker y el JS no.

### 2. Prueba RLS de ejemplo `supabase/tests/rls-ejemplo.test.sql`
- Todo dentro de `begin; … rollback;` → nada persiste.
- `create extension if not exists pgtap with schema extensions` (Supabase local la trae disponible).
- Tabla temporal de ejemplo `public.rls_ejemplo (id, owner_id uuid, nota)` con RLS activado y política `select` `owner_id = auth.uid()`.
- Datos: 2 filas, una por usuario A y B, insertadas como `postgres`.
- Simulación de roles (patrón ADR-0001): `set local role anon|authenticated` + `set local request.jwt.claims = '{"sub":"<uuid>","role":"authenticated"}'`; `reset role` entre casos.
- Casos: `anon` ve 0; A ve 1 y es la suya; B ve 1 y es la suya; A no ve la de B.
- TDD: primero se escriben los casos sin RLS ni política → fallan (A ve 2) → se agregan RLS + política → verde.
- Comentario arriba del archivo: copiar este patrón para cada tabla real.

### 3. README
- Sección "Tests" bajo "Entorno de desarrollo": `pnpm test` (JS, sin Docker) y `pnpm db:start` + `pnpm test:db` (RLS). Dónde van los archivos de cada suite y el ciclo rojo → verde.

## Riesgos
- Puertos 54321–54324 ocupados por otro stack Supabase → `supabase stop --project-id <otro>` antes de `pnpm db:start`.
- Windows: `supabase test db` corre en el contenedor; no requiere `pg_prove` local.
