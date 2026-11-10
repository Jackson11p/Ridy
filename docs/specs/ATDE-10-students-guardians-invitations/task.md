# ATDE-10 — Tareas

- [ ] ATDE-10-T01 `students` (FK compuesta a `schools`) + RLS owner/staff; prueba `supabase/tests/students.test.sql`
- [ ] ATDE-10-T02 `guardian_relationship`, `guardians` + `private.is_guardian_of` + RLS owner/staff/padre; select de `students` para padre y de `profiles` de encargados para owner/staff; prueba `supabase/tests/guardians.test.sql`
- [ ] ATDE-10-T03 `invitations` (rol xor estudiante, vencimiento, pendiente único) + RLS owner/staff; prueba `supabase/tests/invitations.test.sql`
- [ ] ATDE-10-T04 `docs/contexto/convenciones.md`: marcadores [IMPL ATDE-10]
