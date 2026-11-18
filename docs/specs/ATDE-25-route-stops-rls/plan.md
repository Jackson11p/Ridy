# ATDE-25 — Plan

Solo BD. Una migración por tarea vía `pnpm db:migration atde25_<nombre>`; nunca se edita una aplicada. Cada tarea: prueba pgTAP primero (rojo), luego migración (verde). Patrón: ATDE-9/10 (`..._atde9_create_schools.sql`, `..._atde10_create_students.sql`) y sus pruebas. Reutiliza `private.has_role`, `private.is_guardian_of`, `private.set_updated_at`. Pruebas < 150 líneas.

## Referencias
- `docs/arquitectura-sistema.md`: cadena Estudiante → Parada → Ruta → Buseta → Chofer; tabla Quién ve qué.
- `docs/constitution.md` §6: RLS en toda tabla; ubicación de menores solo a padres y con ruta activa.

## 1. Tabla y owner/staff (T01)
- `routes` gana `unique (id, operator_id)` para la FK compuesta (como `students`/`schools`).
- `route_stops`: `id`, `operator_id → operators`, `route_id` y `student_id` con FKs compuestas por empresa, `location geography(Point, 4326) not null`, `stop_order int > 0`, `notify_radius_m int default 500` entre 100 y 2000, `active`, fechas.
- Índice único parcial `(route_id, student_id) where active`; índices por `operator_id`, `route_id`, `student_id`; GIST en `location`; trigger `updated_at`.
- Grants por columna: insert sin fechas; update solo `location`, `stop_order`, `notify_radius_m`, `active` (ruta y estudiante fijos → historial). Sin delete.
- Políticas select/insert/update owner/staff con `has_role(operator_id, '{owner,staff}')`.
- Prueba `supabase/tests/route-stops.test.sql`: columnas y defaults, checks, FKs de otra empresa, duplicado activo, AM y PM del mismo niño, desactivar y recrear, owner/staff/otra empresa/anon, sin delete.

## 2. Padre y chofer (T02)
- Helper `private.is_active_route(route uuid)` `security definer`, `search_path=''`: el padre no ve `routes` por RLS y la subconsulta daría vacío.
- Política select del padre: parada activa, `is_guardian_of(student_id)` y ruta activa.
- Sin política de chofer (supuesto de spec).
- Prueba `supabase/tests/route-stops-parent.test.sql`: dos familias; padre ve AM y PM de su hijo, no los de otro niño; parada inactiva, ruta inactiva, estudiante inactivo y vínculo inactivo → nada; padre no inserta/edita; chofer habitual de la buseta ve 0.

## 3. Tipos (T03)
- `pnpm db:types` regenera `packages/shared/src/database.types.ts`; `pnpm typecheck` en verde.

## Riesgos
- Fuga de direcciones entre familias o empresas → FKs compuestas, helpers con `auth.uid()`, pruebas con dos familias y dos empresas.
- Recursión de RLS route_stops ↔ routes/guardians → helpers `security definer` sin leer route_stops.
