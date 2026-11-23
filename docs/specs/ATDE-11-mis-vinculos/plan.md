# ATDE-11 — Plan

## Módulo 1: RPC `public.my_links()` (migración `atde11_my_links`)
- `language plpgsql`, `stable`, `security definer`, `search_path = ''` (patrón de `create_operator` y `private.has_role`).
- Devuelve `table (kind text, operator_id uuid, operator_name text, role membership_role, student_id uuid, student_name text)`.
  - `membership`: una fila por rol activo; `student_*` nulos.
  - `guardian`: una fila por hijo activo; `role` nulo.
- Unión de dos lecturas, ambas filtradas por `auth.uid()` y `profiles.active`:
  - `memberships` activas ⨝ `operators`.
  - `guardians` activos ⨝ `students` activos ⨝ `operators`.
- Orden estable: `kind`, `operator_name`, `role`, `student_name`, para que la app y las pruebas no dependan del plan del query.
- Sin usuario (`auth.uid()` nulo): `plpgsql` con `raise ... 28000` antes del `return query` (consistente con `create_operator`).
- Grants: `revoke execute ... from public, anon`; `grant execute ... to authenticated`.
- No crea tablas ni políticas: la RLS existente no cambia; el aislamiento lo da el filtro por `auth.uid()` y la ausencia de parámetros.

## Módulo 2: pruebas pgTAP (`supabase/tests/my-links.test.sql`)
- Datos: dos empresas A y B; colegio y estudiantes en A.
- Personas: solo encargado (2 hijos, uno inactivo), solo chofer, dueño (owner + driver), varios roles (chofer en A + encargado), sin vínculos, perfil inactivo con vínculos, membresía y vínculo inactivos, persona de B.
- Casos: los 5 de la arquitectura con `results_eq`; aislamiento (ninguna fila con datos de otra persona, B no ve nada de A); `anon` → `42501`; sin usuario → `28000`; perfil inactivo → vacío; función definer con `search_path` vacío y sin argumentos.

## Módulo 3: tipos y convenciones
- `pnpm db:types` regenera `packages/shared/src/database.types.ts` (sección `Functions`).
- `docs/contexto/convenciones.md`: "la app pregunta permisos a la BD" pasa a [IMPL ATDE-11].

## Riesgos
- `security definer` expone datos si el filtro falla → pruebas de aislamiento cubren cada rama de la unión.
- Ubicación de menores: la RPC no la toca (constitución §6).
