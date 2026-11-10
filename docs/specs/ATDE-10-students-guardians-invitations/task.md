# ATDE-10 — Tareas

- [x] ATDE-10-T01 `students` (FK compuesta a `schools`) + RLS owner/staff; prueba `supabase/tests/students.test.sql`
  - Rojo: 25/25 fallan (`relation "public.students" does not exist`). Verde: `pnpm db:reset` OK, `pnpm test:db` 14 archivos / 246 pruebas PASS.
- [x] ATDE-10-T02 `guardian_relationship`, `guardians` + `private.is_guardian_of` + RLS owner/staff/padre; select de `students` para padre y de `profiles` de encargados para owner/staff; prueba `supabase/tests/guardians.test.sql`
  - Rojo: 31/31 y 20/20 fallan (`relation "public.guardians" does not exist`). Verde: 16 archivos / 297 PASS. Mutación: sin `active` en el with check del padre o sin trigger de avisos → fallan 2+2.
- [x] ATDE-10-T03 `invitations` (rol xor estudiante, vencimiento, pendiente único) + RLS owner/staff; prueba `supabase/tests/invitations.test.sql`
  - Rojo: 20/20 y 30/30 (`invitations-rls.test.sql`) fallan (`relation "public.invitations" does not exist`). Verde: 18 archivos / 347 PASS. Mutación: índice sin `nulls not distinct` → fallan 2.
- [x] ATDE-10-T04 `docs/contexto/convenciones.md`: marcadores [IMPL ATDE-10]
  - Solo docs (sin prueba): tablas nuevas en naming, "sin datos sensibles de niños" y vínculos/invitaciones de rol fuera del cliente pasan a [IMPL ATDE-10].
