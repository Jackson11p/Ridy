# ATDE-17 — Plan

Solo BD. Una migración nueva por tarea vía `pnpm db:migration atde17_<nombre>`; nunca se edita una aplicada. Cada tarea: prueba pgTAP primero (rojo), luego migración (verde). Patrón: `create_operator` (`20261106020534_require_active_profile_valid_timezone.sql`) y su prueba `supabase/tests/create-operator.test.sql`. Reutiliza `private.has_role`.

## Patrón común de las RPC
- `security definer`, `search_path = ''`, en `public` (expuestas por PostgREST).
- `execute` revocado a `public` y `anon`; concedido solo a `authenticated`.
- Sin sesión → `28000`; sin rol requerido en la empresa → `42501`. El rol se valida con `private.has_role`, que ya exige membership y perfil activos.
- Devuelven el id de la fila creada o reactivada.

## 1. `create_operator` atómico (T01)
- Ya cumple el criterio. Solo falta la prueba: forzar que el insert de la membership falle (trigger temporal dentro de la transacción de prueba) y verificar que no queda la empresa. Sin migración.

## 2. `public.invite_driver(operator_id, phone)` (T02)
- Valida sesión y `has_role(operator_id, '{owner,staff}')`.
- Desactiva la invitación pendiente vencida de ese teléfono/rol en la empresa, si la hay.
- Inserta invitación con `role = 'driver'` e `invited_by` = sesión; vencimiento y demás los pone la tabla. Duplicado vigente → `23505` del índice existente; teléfono inválido → `23514`.
- No se tocan grants ni políticas de `invitations`: el cliente sigue sin insertar invitaciones de rol.
- Prueba `supabase/tests/invite-driver.test.sql`.

## 3. `public.add_self_as_driver(operator_id)` (T03)
- Valida sesión y `has_role(operator_id, '{owner}')`.
- Inserta membership `driver` para la sesión; si ya existe (clave única perfil/empresa/rol), la reactiva. La de owner no se toca.
- Prueba `supabase/tests/add-self-as-driver.test.sql`.

## 4. Tipos (T04)
- `pnpm db:types` regenera `packages/shared/src/database.types.ts` con las dos funciones; `tsc` del monorepo en verde.

## Pruebas
- pgTAP por función: definer + search_path, anon, sin sesión, rol no permitido, otra empresa, éxito, efectos (filas creadas, owner conservado, sin duplicados).
- Inserts directos ya cubiertos en `operators-memberships.test.sql` e `invitations-guards.test.sql`; se mantienen.
- Cierre: `pnpm db:reset`, `pnpm test:db`, `pnpm typecheck`, `pnpm lint`, `pnpm test`.
