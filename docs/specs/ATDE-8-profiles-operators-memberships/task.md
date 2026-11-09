# ATDE-8 — Tareas

- [x] ATDE-8-T01 `profiles` + trigger alta desde `auth.users` + RLS propio + grants por columna; prueba `supabase/tests/profiles.test.sql`
- [x] ATDE-8-T02 `membership_role`, `operators`, `memberships`, `private.has_role`, RLS de las dos + select de perfiles de miembros para owner/staff; prueba `supabase/tests/operators-memberships.test.sql`
- [x] ATDE-8-T03 RPC `create_operator` (operator + membership owner); prueba `supabase/tests/create-operator.test.sql`
- [x] ATDE-8-T04 `docs/contexto/convenciones.md`: marcadores [IMPL] de BD

## Correcciones de review
- [x] ATDE-8-T05 Sincronizar `profiles.phone` al cambiar `auth.users.phone`; alta con phone null no rompe
- [x] ATDE-8-T06 Perfiles de miembros: solo memberships activas; `select` por columnas sin `push_token`
- [x] ATDE-8-T07 `has_role` y `create_operator` exigen `profiles.active`; `timezone` válida; pruebas faltantes (driver no edita empresa, owner inactivo pierde update, dos empresas propias)
- [x] ATDE-8-T08 Contrato "nunca \`select *\` en profiles": prueba + convenciones
