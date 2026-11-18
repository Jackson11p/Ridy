# ATDE-25 — Tareas

## Base acordada
- Spec y plan de esta carpeta. Clasificación: CHICA (una capa, 3 tareas), sin agentes.

## Tareas
- [x] ATDE-25-T01 Prueba `route-stops.test.sql` (tabla, checks, FKs, unicidad activa, owner/staff/anon) → migración `atde25_create_route_stops`
  - Rojo: `relation "public.route_stops" does not exist`; verde: `pnpm test:db` 22 archivos, 418 PASS.
- [x] ATDE-25-T02 Prueba `route-stops-parent.test.sql` (padre ve solo sus hijos con ruta activa; chofer 0) → migración `atde25_route_stops_parent` (depende de T01)
  - Rojo: padre ve 0 filas (tests 1 y 9); verde: `pnpm test:db` 23 archivos, 430 PASS.
- [x] ATDE-25-T03 `pnpm db:types` + typecheck (depende de T02)
  - Solo tipos generados (sin prueba propia): `pnpm typecheck`, `pnpm lint` y `pnpm test` (143) en verde.
