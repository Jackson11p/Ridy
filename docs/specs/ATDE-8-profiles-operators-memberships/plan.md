# ATDE-8 — Plan

Solo BD (sin app). Una migración por tarea, vía `pnpm db:migration <nombre>`. Cada tarea: prueba pgTAP en `supabase/tests/` primero (rojo), luego migración (verde). Patrón de roles: `supabase/tests/rls-ejemplo.test.sql`.

## 1. `profiles` (T01)
- `id uuid pk → auth.users(id) on delete cascade`, `full_name text`, `phone text unique`, `push_token text`, `locale text default 'es' check in ('es','en')`, `active bool default true`, `created_at`/`updated_at timestamptz default now()`.
- Trigger `after insert on auth.users` → `private.handle_new_user()` (`security definer`, `search_path = ''`): copia `phone` y `raw_user_meta_data->>'full_name'`.
- RLS: select/update propio (`id = auth.uid()`). Grants por columna: `authenticated` solo actualiza `full_name`, `push_token`, `locale`. Sin insert/delete para clientes.
- Trigger `updated_at` reutilizable: `private.set_updated_at()`.

## 2. `operators` + `memberships` (T02)
- Enum `membership_role` (`owner`,`driver`,`staff`).
- `operators`: `id uuid default gen_random_uuid()`, `name`, `country char(2)`, `currency char(3)`, `timezone text`, `plan text default 'beta'`, `active`, fechas.
- `memberships`: `id uuid`, `profile_id → profiles`, `operator_id → operators`, `role`, `active`, fechas; `unique (profile_id, operator_id, role)` → varios roles = varias filas. Índice por `operator_id`.
- Helper `private.has_role(op uuid, roles membership_role[]) returns bool` (`security definer`, `stable`): membership activa de `auth.uid()`. Evita recursión de RLS en `memberships`. Schema `private` no expuesto por la API; `grant usage`/`execute` a `authenticated`.
- RLS `operators`: select si `has_role(id, todos)`; update si `has_role(id, {owner})`. Sin insert/delete directos.
- RLS `memberships`: select si `profile_id = auth.uid()` o `has_role(operator_id, {owner,staff})`. Sin escrituras directas.
- RLS extra `profiles` (select): owner/staff ven perfiles de personas con membership en su empresa.

## 3. `create_operator` (T03)
- `public.create_operator(name, country, currency, timezone) returns uuid`, `security definer`, `search_path = ''`: exige `auth.uid()`; inserta operator + membership `owner`; devuelve id. `revoke execute from public, anon`; `grant` a `authenticated`.

## 4. Docs (T04)
- `docs/contexto/convenciones.md`: marcar [IMPL] lo que ahora se cumple (RLS desde migración, UUID/UTC, `active`, migraciones vía `db:migration`, pgTAP).

## Riesgos
- `security definer` sin `search_path = ''` → secuestro de funciones. Todas lo fijan y califican nombres.
- Updates de perfil que cambien `phone`/`active` → bloqueado por grants por columna, con prueba.
