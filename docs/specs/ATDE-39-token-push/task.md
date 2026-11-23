# ATDE-39 — Tareas

- [x] ATDE-39-T01 Migración `atde39_push_token`: `check` de formato, RPC `public.set_push_token(token)` con traspaso entre perfiles, revoke de update directo; prueba `supabase/tests/push-token.test.sql`
  - Rojo: 15/15 fallan (`function "public.set_push_token(text)" does not exist`). Verde: `pnpm test:db` 25 archivos / 457 PASS. `profiles.test.sql` y `profiles-members.test.sql` ajustados: el token ya no se edita por update directo.
- [ ] ATDE-39-T02 `pnpm db:types`: regenerar `packages/shared/src/database.types.ts` con `set_push_token`
- [ ] ATDE-39-T03 `packages/shared`: `expoPushTokenSchema` (zod) + test, reexportado en `index.ts`
- [ ] ATDE-39-T04 Dep `expo-notifications` (SDK 58) en `apps/mobile` + plugin en `app.json`; constitución §2 deps aprobadas
- [ ] ATDE-39-T05 `features/notifications` domain + application: contratos, `PushStatus`, `registerPushToken`/`unregisterPushToken` con dobles en `testing/`; tests
- [ ] ATDE-39-T06 `features/notifications/infrastructure`: provider Expo (canal Android, `projectId`, web/emulador → `unavailable`) y store Supabase (RPC); tests con módulos inyectados
- [ ] ATDE-39-T07 `features/notifications/ui`: contexto, `usePushRegistration(session)` (registro + cambios de token), `PushDeniedNotice` i18n es/en; wiring en `app/_layout.tsx`; tests de hook y ruta
- [ ] ATDE-39-T08 Auth: `AuthGateway.signOut` + Supabase, caso de uso `signOut` que borra el token primero (best effort) y hook `useSignOut`; tests
- [ ] ATDE-39-T09 `docs/contexto/convenciones.md`: token push solo por RPC y un dueño por token → [IMPL ATDE-39]
