# ATDE-17 — Tareas

- [ ] ATDE-17-T01 Prueba: `create_operator` con fallo forzado en membership no deja empresa → sin migración (ya atómico); amplía `supabase/tests/create-operator.test.sql`
- [ ] ATDE-17-T02 Prueba `supabase/tests/invite-driver.test.sql` (owner/staff sí; driver, anon, sin sesión, otra empresa no; vencida se reemplaza) → migración `atde17_invite_driver`
- [ ] ATDE-17-T03 Prueba `supabase/tests/add-self-as-driver.test.sql` (owner sí y conserva owner; staff/driver/otra empresa no; idempotente y reactiva) → migración `atde17_add_self_as_driver`
- [ ] ATDE-17-T04 `pnpm db:types` → `packages/shared/src/database.types.ts` con las dos RPC; `pnpm typecheck` en verde (depende de T02, T03)
