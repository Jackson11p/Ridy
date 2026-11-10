# ATDE-10 — Tareas

- [x] ATDE-10-T01 `students` (FK compuesta a `schools`) + RLS owner/staff; prueba `supabase/tests/students.test.sql`
  - Rojo: 25/25 fallan (`relation "public.students" does not exist`). Verde: `pnpm db:reset` OK, `pnpm test:db` 14 archivos / 246 pruebas PASS.
- [x] ATDE-10-T02 `guardian_relationship`, `guardians` + `private.is_guardian_of` + RLS owner/staff/padre; select de `students` para padre y de `profiles` de encargados para owner/staff; prueba `supabase/tests/guardians.test.sql`
  - Rojo: 31/31 y 20/20 fallan (`relation "public.guardians" does not exist`). Verde: 16 archivos / 297 PASS. Mutación: sin `active` en el with check del padre o sin trigger de avisos → fallan 2+2.
- [x] ATDE-10-T03 `invitations` (rol xor estudiante, vencimiento, pendiente único) + RLS owner/staff; prueba `supabase/tests/invitations.test.sql`
  - Rojo: 20/20 y 30/30 (`invitations-rls.test.sql`) fallan (`relation "public.invitations" does not exist`). Verde: 18 archivos / 347 PASS. Mutación: índice sin `nulls not distinct` → fallan 2.
- [x] ATDE-10-T04 `docs/contexto/convenciones.md`: marcadores [IMPL ATDE-10]
  - Solo docs (sin prueba): tablas nuevas en naming, "sin datos sensibles de niños" y vínculos/invitaciones de rol fuera del cliente pasan a [IMPL ATDE-10].

## Correcciones de review
- [x] ATDE-10-T05 `invitations`: update de owner/staff solo en invitaciones de estudiante (`role is null` en using y with check); insert solo con estudiante activo; pruebas: staff/owner no (des)activan invitación de rol, invitación a estudiante inactivo rechazada
  - Rojo: `invitations-guards.test.sql` falla 5/6 (staff reactiva rol owner, owner desactiva rol, estudiante inactivo aceptado). Verde: 19 archivos / 353 PASS. Ajuste: en `invitations-rls.test.sql` el estudiante de otra empresa ahora lo frena RLS (42501) antes que la FK (23503 sigue probado en `invitations.test.sql`).
- [ ] ATDE-10-T06 `guardians`: padre no ve ni edita su vínculo con estudiante inactivo; prueba ajustada
- [ ] ATDE-10-T07 Pruebas faltantes: política `role is null` aislada del grant, trigger de avisos con staff, padre de empresa B no ve niños ni vínculos de A, chofer no ve perfil de encargado
