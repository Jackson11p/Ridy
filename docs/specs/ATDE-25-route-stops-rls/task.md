# ATDE-25 — Tareas

## Base acordada
- Spec y plan de esta carpeta. Clasificación: CHICA (una capa, 3 tareas), sin agentes.

## Tareas
- [ ] ATDE-25-T01 Prueba `route-stops.test.sql` (tabla, checks, FKs, unicidad activa, owner/staff/anon) → migración `atde25_create_route_stops`
- [ ] ATDE-25-T02 Prueba `route-stops-parent.test.sql` (padre ve solo sus hijos con ruta activa; chofer 0) → migración `atde25_route_stops_parent` (depende de T01)
- [ ] ATDE-25-T03 `pnpm db:types` + typecheck (depende de T02)
