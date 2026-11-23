# ATDE-39 — Tareas

- [x] ATDE-39-T01 Migración `atde39_push_token`: `check` de formato, RPC `public.set_push_token(token)` con traspaso entre perfiles, revoke de update directo; prueba `supabase/tests/push-token.test.sql`
  - Rojo: 15/15 fallan (`function "public.set_push_token(text)" does not exist`). Verde: `pnpm test:db` 25 archivos / 457 PASS. `profiles.test.sql` y `profiles-members.test.sql` ajustados: el token ya no se edita por update directo.
- [x] ATDE-39-T02 `pnpm db:types`: regenerar `packages/shared/src/database.types.ts` con `set_push_token`
  - Rojo: tipos sin `set_push_token` (desalineados con la BD). Verde: +3 líneas en `Functions`; `pnpm typecheck` OK. Nota: el generador tipa `token` como `string` no nulo.
- [x] ATDE-39-T03 `packages/shared`: `expoPushTokenSchema` (zod) + test, reexportado en `index.ts`
  - Rojo: 12/12 fallan (`expoPushTokenSchema` no exportado). Verde: 12/12 PASS; typecheck OK.
- [x] ATDE-39-T04 Dep `expo-notifications` (SDK 58) en `apps/mobile` + plugin en `app.json`; constitución §2 deps aprobadas
  - Config sin prueba nueva: `expo install` fijó `expo-notifications` ~58.1.9 (con pnpm). Verde: typecheck OK; `pnpm test` 23 suites / 155 PASS.
- [ ] ATDE-39-T05 `features/notifications` domain + application: contratos, `PushStatus`, `registerPushToken`/`unregisterPushToken` con dobles en `testing/`; tests
- [ ] ATDE-39-T06 `features/notifications/infrastructure`: provider Expo (canal Android, `projectId`, web/emulador → `unavailable`) y store Supabase (RPC); tests con módulos inyectados
- [ ] ATDE-39-T07 `features/notifications/ui`: contexto, `usePushRegistration(session)` (registro + cambios de token), `PushDeniedNotice` i18n es/en; wiring en `app/_layout.tsx`; tests de hook y ruta
- [ ] ATDE-39-T08 Auth: `AuthGateway.signOut` + Supabase, caso de uso `signOut` que borra el token primero (best effort) y hook `useSignOut`; tests
- [ ] ATDE-39-T09 `docs/contexto/convenciones.md`: token push solo por RPC y un dueño por token → [IMPL ATDE-39]
