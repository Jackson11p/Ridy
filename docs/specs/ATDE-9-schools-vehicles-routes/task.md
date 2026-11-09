# ATDE-9 — Tareas

- [x] ATDE-9-T01 PostGIS + `vehicles` + trigger chofer habitual válido + RLS owner/staff/driver; prueba `supabase/tests/vehicles.test.sql`
  - Rojo: `relation "public.vehicles" does not exist`; verde: `pnpm test:db` 8 archivos, 134 pruebas PASS.
- [x] ATDE-9-T02 `schools` (geografía, radio de geocerca, GIST) + RLS owner/staff; prueba `supabase/tests/schools.test.sql`
  - Rojo: `relation "public.schools" does not exist`; verde: `pnpm test:db` 9 archivos, 156 pruebas PASS.
- [ ] ATDE-9-T03 `route_shift`, `routes` con FKs compuestas, código `RDY-` generado + RLS owner/staff/driver; select de `schools` para driver; prueba `supabase/tests/routes.test.sql`
- [ ] ATDE-9-T04 `docs/contexto/convenciones.md`: marcadores [IMPL ATDE-9]
