# ATDE-10 — Plan

Solo BD. Una migración por tarea vía `pnpm db:migration atde10_<nombre>`; nunca se edita una aplicada. Cada tarea: prueba pgTAP primero (rojo), luego migración (verde). Patrón: ATDE-9 (`20261109213120_atde9_create_schools.sql`, `..._create_routes.sql`) y sus pruebas; reutiliza `private.has_role`, `private.set_updated_at`. Archivos de prueba < 150 líneas (partir si hace falta).

## Patrón común
- `id uuid`, `operator_id → operators`, `active`, fechas `timestamptz`, trigger `updated_at`, índice por `operator_id`, RLS en la migración creadora, sin grants ni políticas `delete`.
- FKs compuestas `(x_id, operator_id)` para no mezclar empresas; `students` expone `unique (id, operator_id)`.
- Grants por columna: `update` nunca incluye `id`, `operator_id`, fechas ni columnas de identidad.

## 1. `students` (T01)
- `full_name text` no vacío; `school_id` FK compuesta a `schools`. Sin columnas sensibles.
- Owner/staff: select/insert/update con `has_role(operator_id, '{owner,staff}')`. Política de padre llega en T02.

## 2. `guardians` (T02)
- Enum `guardian_relationship`. `student_id` FK compuesta a `students`; `profile_id → profiles`; `relationship not null`; `receives_notifications bool default true`; `unique (student_id, profile_id)`; índice por `profile_id`.
- Sin insert desde clientes. Owner/staff: select + update (`active`). Padre: select de su fila (`profile_id = auth.uid()`, activa) + update solo `receives_notifications` (grant por columna; política `using/with check profile_id = auth.uid()`).
- Política padre en `students`: activo y existe `guardians` activo propio. Helper `private.is_guardian_of(student uuid)` (`security definer`, `search_path=''`, exige `profiles.active`) para evitar recursión students ↔ guardians.
- Política extra `profiles` (select): owner/staff ven perfiles con vínculo `guardians` activo en su empresa.
- Ajuste T02: los grants por columna son por rol (`authenticated`), no por política. `update (active, receives_notifications)` + trigger `guardians_guard_notifications` (42501 si un cliente cambia los avisos de un vínculo que no es suyo) + `with check (... and active)` en la política del padre (no se desactiva).
- Pruebas partidas: `guardians.test.sql` (owner/staff/driver/otra empresa) y `guardians-parent.test.sql` (familias).

## 3. `invitations` (T03)
- `phone text check '^[0-9]{8,15}$'`; `role membership_role null`; `student_id null` FK compuesta; `relationship guardian_relationship null`; `check (num_nonnulls(role, student_id) = 1)`; `check ((student_id is null) = (relationship is null))`.
- `invited_by uuid not null default auth.uid() → profiles`; `expires_at default now() + 14 days`; `accepted_at null`.
- Índice único parcial de pendientes: `(operator_id, phone, role, student_id) nulls not distinct where active and accepted_at is null`.
- Owner/staff: select; insert solo con `role is null` (de estudiante); update solo `active`. Grants de insert sin `invited_by`, `expires_at`, `accepted_at`.

## 4. Docs (T04)
- `docs/contexto/convenciones.md`: [IMPL ATDE-10] "sin fotos ni datos sensibles de niños" y escrituras sensibles (vínculos) fuera del cliente.

## 5. Correcciones de review (T05–T07)
- Migraciones nuevas. `invitations`: recrear política update con `role is null` en `using`/`with check`; política insert exige estudiante activo (subconsulta a `students` bajo RLS de owner/staff). `guardians`: política select/update del padre exige estudiante activo (vía helper `security definer` o subconsulta sin ciclo). Política `role is null` se prueba aislada (p. ej. update de `active` sobre invitación de rol creada como postgres).

## Riesgos
- Fuga de niños entre empresas o entre familias → FKs compuestas, helper con `auth.uid()`, pruebas con dos familias y dos empresas.
- Staff escalando con invitación de rol owner → insert de rol prohibido + prueba.
- Recursión de RLS students ↔ guardians → helper `security definer`.
