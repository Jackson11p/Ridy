# ATDE-11 — Tareas

- [x] ATDE-11-T01 RPC `public.my_links()` (membresías + hijos de `auth.uid()`); prueba `supabase/tests/my-links.test.sql` con los 5 casos, aislamiento, `anon`, sin usuario y perfil inactivo
  - Rojo: 12/12 fallan (`function "public.my_links()" does not exist`). Verde: `pnpm test:db` 20 archivos / 372 PASS.
- [x] ATDE-11-T02 `pnpm db:types`: regenerar `packages/shared/src/database.types.ts` con `my_links`; tsc, lint y tests de `packages/shared` en verde
  - Rojo: tipos sin `my_links` (los desalinea el check de CI). Verde: +5 líneas en `Functions`; typecheck, lint y `pnpm test` (55/55) OK. Nota: el generador marca `role`/`student_*` como no nulos; el consumidor (ATDE-16) valida con zod en el límite.
- [x] ATDE-11-T03 `docs/contexto/convenciones.md`: permisos se preguntan a la BD vía RPC → [IMPL ATDE-11]
  - Solo docs (sin prueba): nueva regla en "Patrones que usamos".
