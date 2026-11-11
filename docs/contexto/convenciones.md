# Convenciones — [NOMBRE_PRODUCTO]

> Leyenda: **[IMPL]** se cumple hoy en el repo · **[PLAN]** regla escrita, sin código que la aplique aún.
> Reglas maestras: `docs/constitution.md` (gana sobre cualquier spec) y `Claude.md`.

## Idioma

- Docs, specs, commits, UI: **español**. [IMPL en docs]
- Código, tablas, nombres técnicos: **inglés** (`docs/arquitectura-sistema.md`). [PLAN]
- Textos de app en español e inglés vía i18n. [PLAN]

## Naming

- Tablas en inglés, plural, snake_case: `vehicles`, `schools`, `routes`, `students`, `guardians`, `invitations`, `route_stops`, `trip_events`. [IMPL ATDE-9, ATDE-10]
- Roles de membresía: `owner`, `driver`, `staff`. [PLAN]
- Specs: `docs/specs/TICKET-nombre/` (ej. `RIDY-0001-conectar-docker`). Tareas: `TICKET-Tnn`. [IMPL]
- Scripts BD: prefijo `db:` (`db:start`, `db:reset`, …). [IMPL]
- Migraciones: `supabase/migrations/<timestamp>_<nombre>.sql` vía `pnpm db:migration`. [IMPL ATDE-8]
- Componentes: [PENDIENTE: convención de archivos/componentes React Native]

## Patrones que usamos

- **Spec antes de código**: `spec.md` (10–30 líneas) → `plan.md` (20–50) → `task.md` (máx. 100). [IMPL en RIDY-0001]
- Seguridad en BD, no en app: RLS en toda tabla desde su migración creadora. [IMPL ATDE-8]
- `profiles`: clientes listan columnas, nunca `select *` (falla con 42501: `push_token` no se lee). [IMPL ATDE-8]
- Escrituras sensibles (aprobar solicitudes, mover estudiantes, cambiar chofer) por **funciones SQL** o del servidor, no inserts directos. [PLAN; IMPL ATDE-10: vínculos `guardians` sin insert desde el cliente; invitaciones de rol solo desde el servidor; `invited_by` y vencimiento los pone la BD]
- Nada se borra físicamente: se desactiva (`active`). [IMPL ATDE-8: sin grants ni políticas delete]
- Toda tabla de operación lleva `operator_id`; RLS filtra por él. [IMPL ATDE-9]
- Referencias entre tablas de operación con FK compuesta `(x_id, operator_id)` → `unique (id, operator_id)`: imposible mezclar empresas. [IMPL ATDE-9]
- UUID como llave visible; fechas en UTC (`timestamptz`). [IMPL ATDE-8]
- I/O (Supabase, GPS, push) aislado tras contratos; cero lógica de negocio en UI. [PLAN]
- Archivos < 150 líneas, funciones < 30. [PLAN]
- Mínimas dependencias; nueva dep = decisión de socios. [IMPL: solo 3 deps]

Capas: `apps/mobile/src/features/<f>/domain|application|infrastructure|ui` + `index.ts`; `ui → application → domain`, `infrastructure` implementa contratos (`docs/adr/0001-capas-y-runner.md`). [PLAN]

## Prohibido

- `npm install` (falla a propósito con `EBADENGINE`). Solo pnpm. [IMPL]
- Editar una migración ya aplicada; cambiar schema a mano en Studio sin migración. [PLAN]
- `service_role` en app o repo; solo en Edge Functions. [PLAN]
- Subir `.env*` (salvo `.env.example`). [IMPL vía `.gitignore`]
- Silenciar errores con `any`, `@ts-ignore`, `eslint-disable` (`coder.md`). [PLAN]
- Fotos de niños, fechas de nacimiento, cédulas, datos médicos. [IMPL ATDE-10: `students` solo nombre, colegio y estado; prueba `columns_are`]

## Tests

- TDD obligatorio: rojo → verde → refactor; sin test no hay commit; bug fix empieza con test. [PLAN]
- Toda tabla con RLS tiene prueba RLS (`supabase/tests/`). [IMPL ATDE-8; job CI `test-rls` PLAN]
- Runner: `jest-expo` + `@testing-library/react-native` (JS/TS); pgTAP vía `supabase test db`, archivos `supabase/tests/*.test.sql` (ADR-0001). [IMPL jest-expo (ATDE-6), pgTAP (ATDE-7/ATDE-8)]. Tests de rutas van en `apps/mobile/__tests__/`: dentro de `app/` Expo Router los tomaría como pantallas.
- Excepción usada: RIDY-0001 sin código de dominio → verificación manual. [IMPL]

## Commits

- Formato pedido (`coder.md`): `<tipo>(<ámbito>): TICKET-Tnn <descripción>`. Un commit por tarea. [PLAN]
- Realidad del historial: mezcla (`docs: llenar constitución…`, `mejorando md`). [PENDIENTE: exigir formato desde ya]
- Commits con IA llevan `Co-Authored-By`. [IMPL en `ae9bf3e`]
- Cambios necesitan aprobación de un socio distinto al autor (`CODEOWNERS`). [IMPL, requiere protección de rama en GitHub — PENDIENTE: confirmar activa]
- Archivos generados (`packages/shared/src/database.types.ts`, por `pnpm db:types`) no se editan a mano y quedan exentos del límite de 150 líneas y de lint/formato. [IMPL ATDE-13]
