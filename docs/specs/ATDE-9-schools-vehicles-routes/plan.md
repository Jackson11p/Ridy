# ATDE-9 — Plan

Solo BD (sin app). Una migración por tarea vía `pnpm db:migration <nombre>`; nunca se edita una ya aplicada. Cada tarea: prueba pgTAP en `supabase/tests/` primero (rojo), luego migración (verde). Patrón de fixtures y roles: `supabase/tests/operators-memberships.test.sql`. Reutiliza `private.has_role` y `private.set_updated_at` (ATDE-8).

## Patrón común de tabla
- `id uuid default gen_random_uuid()`, `operator_id → operators` not null, `active bool default true`, `created_at`/`updated_at timestamptz`, trigger `updated_at`, índice por `operator_id`, RLS en la migración creadora.
- `unique (id, operator_id)` en `vehicles` y `schools` → `routes` usa FKs compuestas `(school_id, operator_id)` y `(vehicle_id, operator_id)`: imposible mezclar empresas.
- Grants: `revoke all` a `anon`/`authenticated`; `select` + `insert`/`update` por columnas a `authenticated`. `update` nunca incluye `operator_id`, `id`, fechas ni `code`. Sin `delete`.
- Políticas owner/staff: `select`, `insert`, `update` con `private.has_role(operator_id, '{owner,staff}')` en `using` y `with check`.

## 1. PostGIS + `vehicles` (T01)
- `create extension if not exists postgis with schema extensions`.
- `plate text` no vacía, `unique (operator_id, plate)`; `capacity int check 1..60`; `default_driver_id uuid → profiles` nullable.
- Trigger `before insert or update` → `private.check_default_driver()` (`security definer`, `search_path = ''`): si hay chofer, debe tener membership `driver` activa en esa empresa; si no, error `23514`.
- Política chofer (select): `active and default_driver_id = auth.uid() and has_role(operator_id, '{driver}')`.
- Ajuste T01: trigger solo en `insert or update of default_driver_id, operator_id` (editar placa de una buseta cuyo chofer se desactivó no falla); sin índice aparte por `operator_id`: lo cubre `unique (operator_id, plate)`.

## 2. `schools` (T02)
- `name text` no vacío; `location extensions.geography(Point, 4326) not null`; `geofence_radius_m int default 200 check 50..2000`; índice GIST en `location`.
- Política chofer se agrega en T03 (depende de `routes`).

## 3. `routes` (T03)
- Enum `route_shift` (`am`, `pm`). Columnas: `school_id`, `vehicle_id` (FKs compuestas), `shift`, `code text unique not null default private.generate_route_code()` con `check (code ~ '^RDY-[A-Z0-9]{6}$')`.
- `private.generate_route_code()`: `RDY-` + 6 caracteres de alfabeto sin ambiguos (sin 0/O/1/I), aleatorio con `gen_random_bytes`; colisión → violación de `unique` (probabilidad despreciable en beta).
- Políticas chofer (select): `routes` activas cuya buseta es visible para él (subconsulta a `vehicles` bajo su RLS); `schools` activas referenciadas por una ruta visible para él. Sin ciclos de RLS: vehicles ← routes ← schools.

## 4. Docs (T04)
- `docs/contexto/convenciones.md`: marcar [IMPL ATDE-9] "toda tabla de operación lleva `operator_id`", tablas plural snake_case y FKs compuestas por empresa.

## Riesgos
- Fuga entre empresas por FK a fila de otra empresa → FKs compuestas + prueba.
- Chofer escalando a escritura → sin políticas de escritura para driver + prueba.
- Chofer desactivado o perfil inactivo sigue viendo → `has_role` ya lo cubre; prueba.
