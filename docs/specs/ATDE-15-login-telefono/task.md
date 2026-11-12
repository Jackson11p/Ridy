# ATDE-15 — Tareas

- [x] ATDE-15-T01 Spec, plan y tareas
- [x] ATDE-15-T02 Deps `@supabase/supabase-js` ^2.118.0 y AsyncStorage (`expo install`) en mobile, mock de AsyncStorage en jest, constitución §2; `src/services/supabase.ts` (perezoso, error claro sin env) con test
  - Rojo: `src/services/supabase.test.ts` → jest `Cannot find module './supabase'`. Verde: 2 PASS (sin env lanza error claro; con env un único cliente que lee sesión de AsyncStorage); mock oficial vía `moduleNameMapper` en la config jest; `expo install` fijó async-storage 2.2.0; sin cambios en `pnpm-workspace.yaml`; typecheck/lint OK, `pnpm test` 12 suites/57 PASS.
- [ ] ATDE-15-T03 `features/auth/domain`: tipos, contrato `AuthGateway`, errores, regla código 6 dígitos y segundos para reenviar; tests
- [ ] ATDE-15-T04 `features/auth/application`: `requestCode` y `verifyCode` con gateway falso; tests (depende de T03)
- [ ] ATDE-15-T05 `features/auth/infrastructure`: gateway Supabase y mapeo de errores, cliente simulado; tests (depende de T02, T03)
- [ ] ATDE-15-T06 `features/auth/ui`: `useSession`, `usePhoneForm`, `useCodeForm` (cuenta regresiva 60 s); `index.ts`; tests (depende de T04)
- [ ] ATDE-15-T07 Pantalla `sign-in` (A01) + i18n es/en; tests de render, número inválido y navegación a `verify` (depende de T06)
- [ ] ATDE-15-T08 Pantalla `verify` (A02/A03) + i18n; tests de código correcto/incorrecto, reenviar bloqueado y cambiar número (depende de T06)
- [ ] ATDE-15-T09 Redirección por sesión en `app/index.tsx` y `(auth)/_layout.tsx`; actualizar `__tests__/routes.test.tsx` (depende de T06)
- [ ] ATDE-15-T10 Verificación: `pnpm typecheck`, `pnpm lint`, `pnpm test`, `pnpm test:db`, `expo export --platform android`; prueba manual en navegador con `50670000001`/`123456`
