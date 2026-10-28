# Convenciones — [NOMBRE_PRODUCTO]

> Leyenda: **[IMPL]** se cumple hoy en el repo · **[PLAN]** regla escrita, sin código que la aplique aún.
> Reglas maestras: `docs/constitution.md` (gana sobre cualquier spec) y `Claude.md`.

## Idioma

- Docs, specs, commits, UI: **español**. [IMPL en docs]
- Código, tablas, nombres técnicos: **inglés** (`docs/arquitectura-sistema.md`). [PLAN]
- Textos de app en español e inglés vía i18n. [PLAN]

## Naming

- Tablas en inglés, plural, snake_case: `route_stops`, `trip_events`, `notifications_log`. [PLAN]
- Roles de membresía: `owner`, `driver`, `staff`. [PLAN]
- Specs: `docs/specs/TICKET-nombre/` (ej. `RIDY-0001-conectar-docker`). Tareas: `TICKET-Tnn`. [IMPL]
- Scripts BD: prefijo `db:` (`db:start`, `db:reset`, …). [IMPL]
- Migraciones: `supabase/migrations/<timestamp>_<nombre>.sql` vía `pnpm db:migration`. [PLAN]
- Componentes: [PENDIENTE: convención de archivos/componentes React Native]

## Patrones que usamos

- **Spec antes de código**: `spec.md` (10–30 líneas) → `plan.md` (20–50) → `task.md` (máx. 100). [IMPL en RIDY-0001]
- Seguridad en BD, no en app: RLS en toda tabla desde su migración creadora. [PLAN]
- Escrituras sensibles (aprobar solicitudes, mover estudiantes, cambiar chofer) por **funciones SQL**, no inserts directos. [PLAN]
- Nada se borra físicamente: se desactiva (`activa`). [PLAN]
- Toda tabla de operación lleva `operator_id`; RLS filtra por él. [PLAN]
- UUID como llave visible; fechas en UTC. [PLAN]
- I/O (Supabase, GPS, push) aislado tras contratos; cero lógica de negocio en UI. [PLAN]
- Archivos < 150 líneas, funciones < 30. [PLAN]
- Mínimas dependencias; nueva dep = decisión de socios. [IMPL: solo 3 deps]

Capas: [PENDIENTE: constitución las deja `[POR DEFINIR]`; arquitectura propone `src/features|components|services`; agentes (`coder`, `planner`) asumen `src/modules/<m>/domain|application|infrastructure|ui`. Elegir una.]

## Prohibido

- `npm install` (falla a propósito con `EBADENGINE`). Solo pnpm. [IMPL]
- Editar una migración ya aplicada; cambiar schema a mano en Studio sin migración. [PLAN]
- `service_role` en app o repo; solo en Edge Functions. [PLAN]
- Subir `.env*` (salvo `.env.example`). [IMPL vía `.gitignore`]
- Silenciar errores con `any`, `@ts-ignore`, `eslint-disable` (`coder.md`). [PLAN]
- Fotos de niños, fechas de nacimiento, cédulas, datos médicos. [PLAN]

## Tests

- TDD obligatorio: rojo → verde → refactor; sin test no hay commit; bug fix empieza con test. [PLAN]
- Toda tabla con RLS tiene prueba RLS (`supabase/tests/`, job CI `test-rls`). [PLAN]
- Runner: [PENDIENTE: elegir runner JS y de pruebas SQL/RLS]
- Excepción usada: RIDY-0001 sin código de dominio → verificación manual. [IMPL]

## Commits

- Formato pedido (`coder.md`): `<tipo>(<ámbito>): TICKET-Tnn <descripción>`. Un commit por tarea. [PLAN]
- Realidad del historial: mezcla (`docs: llenar constitución…`, `mejorando md`). [PENDIENTE: exigir formato desde ya]
- Commits con IA llevan `Co-Authored-By`. [IMPL en `ae9bf3e`]
- Cambios necesitan aprobación de un socio distinto al autor (`CODEOWNERS`). [IMPL, requiere protección de rama en GitHub — PENDIENTE: confirmar activa]
