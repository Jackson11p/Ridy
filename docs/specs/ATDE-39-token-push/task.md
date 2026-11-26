# ATDE-39 — Tareas

- [x] ATDE-39-T01 Migración `atde39_push_token`: `check` de formato, RPC `public.set_push_token(token)` con traspaso entre perfiles, revoke de update directo; prueba `supabase/tests/push-token.test.sql`
  - Rojo: 15/15 fallan (`function "public.set_push_token(text)" does not exist`). Verde: `pnpm test:db` 25 archivos / 457 PASS. `profiles.test.sql` y `profiles-members.test.sql` ajustados: el token ya no se edita por update directo.
  - Corrección (migración `atde39_set_push_token_default_null` + tipos): `token default null` para borrar sin argumento (el generador tipaba `token` como `string` no nulo). Rojo: 2/17 fallan (`set_push_token()` no existe). Verde: 25 archivos / 459 PASS; tipos `"token"?: string`.
- [x] ATDE-39-T02 `pnpm db:types`: regenerar `packages/shared/src/database.types.ts` con `set_push_token`
  - Rojo: tipos sin `set_push_token` (desalineados con la BD). Verde: +3 líneas en `Functions`; `pnpm typecheck` OK. Nota: el generador tipa `token` como `string` no nulo.
- [x] ATDE-39-T03 `packages/shared`: `expoPushTokenSchema` (zod) + test, reexportado en `index.ts`
  - Rojo: 12/12 fallan (`expoPushTokenSchema` no exportado). Verde: 12/12 PASS; typecheck OK.
- [x] ATDE-39-T04 Dep `expo-notifications` (SDK 58) en `apps/mobile` + plugin en `app.json`; constitución §2 deps aprobadas
  - Config sin prueba nueva: `expo install` fijó `expo-notifications` ~58.1.9 (con pnpm). Verde: typecheck OK; `pnpm test` 23 suites / 155 PASS.
- [x] ATDE-39-T05 `features/notifications` domain + application: contratos, `PushStatus`, `registerPushToken`/`unregisterPushToken` con dobles en `testing/`; tests
  - Rojo: suite falla (`Cannot find module '../testing/fake-push'`, casos de uso inexistentes). Verde: 11/11 PASS; tsc y eslint OK. Extra: `savePushToken` (valida y guarda un token rotado).
- [x] ATDE-39-T06 `features/notifications/infrastructure`: provider Expo (canal Android, `projectId`, web/emulador → `unavailable`) y store Supabase (RPC); tests con módulos inyectados
  - Rojo: 2 suites fallan (`Cannot find module './expo-push-token-provider'` y `'./supabase-push-token-store'`). Verde: 12 casos nuevos, feature 23/23 PASS; tsc y eslint OK. Borrar = `rpc('set_push_token', {})`.
- [x] ATDE-39-T07 `features/notifications/ui`: contexto, `usePushRegistration(session)` (registro + cambios de token), `PushDeniedNotice` i18n es/en; wiring en `app/_layout.tsx`; tests de hook y ruta
  - Rojo: suites de hook y aviso fallan (`Cannot find module`); rutas 3 nuevas fallan (sin `@/features/notifications`). Verde: hook 6/6, aviso 5/5, rutas 11/11 (2.ª corrida; la 1.ª en frío dio timeout de 5 s en el primer caso); tsc y eslint OK.
- [x] ATDE-39-T08 Auth: `AuthGateway.signOut` + Supabase, caso de uso `signOut` que borra el token primero (best effort) y hook `useSignOut`; tests
  - Rojo: 3 suites sin módulo (`sign-out`, `use-sign-out`, `use-clear-push-token`) y `gateway.signOut is not a function`. Verde: 17/17 PASS; tsc y eslint OK. Dirección: `useSignOut(beforeSignOut)` en auth recibe la limpieza; `useClearPushToken()` en notificaciones la da; `app/` las compone.
- [x] ATDE-39-T09 `docs/contexto/convenciones.md`: token push solo por RPC y un dueño por token → [IMPL ATDE-39]
  - Solo docs (sin prueba): nueva regla en "Patrones que usamos".

## Correcciones de review
- [x] ATDE-39-T10 BD: índice único parcial `profiles(push_token) where push_token is not null` (un token nunca en dos perfiles ante concurrencia); prueba de duplicado → `23505`
  - Rojo: 1/19 falla ("mismo token en dos perfiles se rechaza": el update duplicado pasa). Verde: migración `atde39_push_token_unique`; `test db` 25 archivos / 461 PASS.
- [x] ATDE-39-T11 BD: `set_push_token(null)` permitido con perfil inactivo (borrar sí, guardar no); prueba; convenciones: `notify` debe filtrar `profiles.active`
  - Rojo: 2/21 fallan (inactivo no borra: 42501). Verde: migración `atde39_inactive_clears_push_token`; 25 archivos / 463 PASS. Firma igual: tipos sin cambio.
- [x] ATDE-39-T12 Provider Expo: en Android crear canal `default` antes de pedir/consultar permiso (Android 13+); ajustar prueba de orden
  - Rojo: 1/11 falla (canal se creaba después del permiso, al pedir token). Verde: provider 12/12, feature 37/37 PASS; tsc y eslint OK.
- [x] ATDE-39-T13 `usePushRegistration`: estado vuelve a null al cambiar de `userId`; `PushDeniedNotice` también en `unavailable` (spec req. 3) con su texto i18n; pruebas A → B y aviso
  - Rojo: 3/14 fallan (B hereda `denied` de A; sin aviso ni texto `notifications.unavailable`). Verde: estado guardado con su `userId` (sin setState en el effect, regla lint); feature + rutas 50/50 PASS (rutas: 1.ª corrida timeout en frío); tsc y eslint OK.
- [x] ATDE-39-T14 Cierre de sesión sin carrera: la limpieza corta el listener y espera el guardado pendiente antes de `clear()`; prueba de save en curso al cerrar sesión
  - Rojo: suite `serial-push-store` sin módulo; 2 casos de `useClearPushToken` fallan (save tardío tras el borrado; clear sin esperar). Verde: `createSerialPushStore` (cola en orden; tras `clear` descarta saves hasta `open()` de sesión nueva), montado en `PushRegistryProvider`; 19 suites / 137 PASS; tsc y eslint OK.

## Correcciones de re-review y test-adversarial
- [x] ATDE-39-T15 Si `signOut` falla tras borrar el token, la limpieza se deshace (reabre store y re-registra, también si borrar falló); prueba de `open()` para la siguiente persona
  - Rojo: 3 fallan (`signOut` sin undo; `useClearPushToken` sin undo; caso adversarial "keeps saving rotated tokens when sign-out fails"). Mutación: sin `store.open()` falla "registers the token again for the next user". Verde: `BeforeSignOut` devuelve undo opcional; 18 suites / 140 PASS; tsc OK.
- [x] ATDE-39-T16 Provider: `onTokenChange` no lanza si `addPushTokenListener` falla en nativo (contrato de domain)
  - Rojo: 1/21 falla (`native missing` sube al effect). Verde: sin módulo, suscripción vacía; infrastructure 21/21 PASS; eslint OK.
