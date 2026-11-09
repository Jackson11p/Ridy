# ATDE-9 — Tareas

- [x] ATDE-9-T01 PostGIS + `vehicles` + trigger chofer habitual válido + RLS owner/staff/driver; prueba `supabase/tests/vehicles.test.sql`
  - Rojo: `relation "public.vehicles" does not exist`; verde: `pnpm test:db` 8 archivos, 134 pruebas PASS.
- [x] ATDE-9-T02 `schools` (geografía, radio de geocerca, GIST) + RLS owner/staff; prueba `supabase/tests/schools.test.sql`
  - Rojo: `relation "public.schools" does not exist`; verde: `pnpm test:db` 9 archivos, 156 pruebas PASS.
- [x] ATDE-9-T03 `route_shift`, `routes` con FKs compuestas, código `RDY-` generado + RLS owner/staff/driver; select de `schools` para driver; prueba `supabase/tests/routes.test.sql`
  - Rojo: `relation "public.routes" does not exist`; verde: `pnpm test:db` 10 archivos, 195 pruebas PASS.
- [x] ATDE-9-T04 `docs/contexto/convenciones.md`: marcadores [IMPL ATDE-9]
  - Solo docs (sin prueba): tablas plural snake_case, `operator_id` en tablas de operación y FKs compuestas.

## Correcciones de review
- [x] ATDE-9-T05 Pruebas: "driver no edita rutas" con valor distinto; partir `routes.test.sql` (< 150 líneas); casos faltantes: `vehicle_id` de otra empresa en update, staff cambia chofer habitual, trigger rechaza como owner, persona owner en B + driver en A
  - Solo pruebas (verde directo, el código ya cumplía). Sensibilidad: con política temporal de update para todos, fallan "driver no edita rutas/colegios" (have pm/"por driver"). `routes.test.sql` + `routes-driver.test.sql` + `vehicles-default-driver.test.sql`; 12 archivos, 209 PASS.
- [ ] ATDE-9-T06 Trigger chofer habitual solo si el valor cambia y exige `profiles.active`; índice por `default_driver_id`
- [ ] ATDE-9-T07 Placa única por empresa sin distinguir mayúsculas ni espacios; check de `code` igual al alfabeto del generador
