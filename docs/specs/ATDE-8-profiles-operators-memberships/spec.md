# ATDE-8 — profiles, operators y memberships con RLS

## Problema
No hay esquema. Login, selector de vista, alta del transportista y toda política por `operator_id` necesitan "una persona con su teléfono" vinculada a una empresa con rol.

## Requisitos
1. Al crearse un usuario en `auth.users` se crea su `profile` (1 a 1): nombre, teléfono, token push, idioma.
2. `operators`: nombre, país, moneda, zona horaria, plan.
3. `memberships`: persona ↔ empresa con rol `owner`, `driver` o `staff`; varios roles por persona y empresa.
4. Crear empresa crea `operator` + `membership` owner de quien la crea, en un solo paso.
5. Llaves UUID, fechas UTC (`timestamptz`), desactivación (`active`) en vez de borrado.

## Criterios de aceptación
- Migraciones en `supabase/migrations/`; `pnpm db:reset` aplica sin errores; `pnpm test:db` en verde.
- RLS en las 3 tablas, con pruebas pgTAP:
  - cada persona ve y edita su perfil (no su teléfono ni `active`);
  - owner/staff ven su empresa, sus memberships y los perfiles de sus miembros;
  - driver ve su empresa y sus propias memberships, no las de otros;
  - nadie ve otras empresas; `anon` no ve nada; nadie borra filas.

## Fuera de alcance
- Invitar choferes/staff, editar o desactivar memberships (ticket de invitaciones), `subscriptions`, Auth OTP (ATDE-9), UI.

## Supuestos
- Ticket Jira `ATDE-8`; rama y carpeta `ATDE-8-profiles-operators-memberships`; tareas `ATDE-8-Tnn`.
- Escritura de empresa + owner por función SQL `create_operator` (regla de arquitectura: escrituras sensibles por funciones), no por insert directo.
- Memberships solo se crean vía `create_operator` en este ticket; resto de escrituras llega con invitaciones.
- `plan` = texto, por defecto `'beta'` (planes reales [POR DEFINIR], no se modelan).
- `locale` solo `es`/`en` (i18n de ATDE-6), por defecto `es`. País ISO-3166 alfa-2, moneda ISO-4217.
- Teléfono único y copiado de `auth.users` (llave de identidad); el usuario no lo edita.
- Borrar en `auth.users` borra en cascada el perfil (derecho de borrado, Ley 8968); fuera de eso nada se borra.
