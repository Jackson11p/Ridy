# ATDE-39 — Plan

## Módulo 1: BD (migración `atde39_push_token`)
- `check` en `profiles.push_token`: nulo o `^Expo(nent)?PushToken\[[^\]]+\]$`, máx. 255.
- RPC `public.set_push_token(token text)` `security definer`, `search_path = ''`: sin usuario → `28000`; perfil inactivo → `42501`; quita ese token de cualquier otro perfil y lo pone en el propio; `null` lo borra.
- `revoke update (push_token)` a `authenticated`: única vía de escritura es la RPC. Lectura sigue oculta (ATDE-8-T06).
- pgTAP `supabase/tests/push-token.test.sql`: guarda, cambia, borra, traspaso entre perfiles, formato inválido, inactivo, sin usuario, `anon`, update directo y lectura (propia y ajena) → `42501`.

## Módulo 2: `packages/shared`
- `expoPushTokenSchema` (zod) igual al `check`, para app y futura Edge Function; reexporte en `index.ts`.

## Módulo 3: feature `apps/mobile/src/features/notifications`
- `domain`: contratos `PushTokenProvider` (pedir permiso, obtener token, escuchar cambios) y `PushTokenStore` (guardar/borrar); `PushStatus` = `registered` | `denied` | `unavailable`.
- `application`: `registerPushToken(provider, store)` → valida con `expoPushTokenSchema`, guarda, devuelve estado; `unregisterPushToken(store)`.
- `infrastructure`: `expo-push-token-provider` (canal Android `default` antes del token, `projectId` de `expo-constants`, web/sin dispositivo → `unavailable`; módulo inyectable para tests); `supabase-push-token-store` (RPC `set_push_token`).
- `ui`: contexto + `usePushRegistration(session)`: registra al haber sesión, escucha cambios de token, expone estado; `PushDeniedNotice` con i18n es/en.
- `testing`: dobles de provider y store.

## Módulo 4: auth — cerrar sesión
- `AuthGateway.signOut()` + implementación Supabase.
- Caso de uso `signOut(auth, unregister)`: borra token (best effort) y luego cierra sesión; hook `useSignOut`.

## Módulo 5: wiring y docs
- `app/_layout.tsx`: provider real de notificaciones junto al de auth; aviso cuando `denied`.
- `app.json`: plugin `expo-notifications`. Constitución §2: dep aprobada. `convenciones.md`: token solo por RPC.

## Riesgos
- Token ajeno → avisos de niños de otra familia: cubierto por traspaso en la RPC (punto 5 de la spec) y su prueba.
- Tests de Expo: `expo-notifications` se inyecta, nunca se llama nativo en Jest.
