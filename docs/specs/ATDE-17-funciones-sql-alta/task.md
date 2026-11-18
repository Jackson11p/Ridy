# ATDE-17 — Tareas

- [x] ATDE-17-T01 Prueba: `create_operator` con fallo forzado en membership no deja empresa → sin migración (ya atómico); amplía `supabase/tests/create-operator.test.sql`
  - Caracterización (sin rojo posible: `create_operator` ya es atómico). Verde: `create-operator.test.sql` 11/11 PASS.
- [x] ATDE-17-T02 Prueba `supabase/tests/invite-driver.test.sql` (owner/staff sí; driver, anon, sin sesión, otra empresa no; vencida se reemplaza) → migración `atde17_invite_driver`
  - Rojo: 13/13 fallan (`function public.invite_driver(uuid, text) does not exist`). Verde: `invite-driver.test.sql` 13/13 PASS.
- [x] ATDE-17-T03 Prueba `supabase/tests/add-self-as-driver.test.sql` (owner sí y conserva owner; staff/driver/otra empresa no; idempotente y reactiva) → migración `atde17_add_self_as_driver`
  - Rojo: 11/11 fallan (`function public.add_self_as_driver(uuid) does not exist`). Verde: `add-self-as-driver.test.sql` 11/11 PASS.
- [x] ATDE-17-T04 `pnpm db:types` → `packages/shared/src/database.types.ts` con las dos RPC; `pnpm typecheck` en verde (depende de T02, T03)
  - Generado (sin rojo). Verde: `pnpm db:reset` OK, `pnpm test:db` 21 archivos / 386 PASS, typecheck + lint OK, jest 57/57.
