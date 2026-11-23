# ATDE-15 — Plan

## Referencias
Constitución §2/§4/§6 · ADR-0001 · ATDE-13 (`@ridy/shared`, `phoneSchema`) · ATDE-14 (`test_otp`, `max_frequency` 60 s) · ATDE-64 (tema, componentes) · Figma A01 `5:3`, A02 `5:24`, A03 `5:56`.

## Diseño (feature `auth`)
- **domain**: tipo `Session` mínimo (id de usuario, teléfono); contrato `AuthGateway` con pedir código, verificar código, leer sesión actual y suscribirse a cambios; errores de dominio (`invalid_phone`, `invalid_code`, `too_soon`, `unknown`). Regla pura: código = exactamente 6 dígitos; segundos restantes para reenviar dado el último envío y el reloj.
- **application**: casos de uso `requestCode` (arma `+506` + dígitos, valida con `phoneSchema`, llama al gateway) y `verifyCode` (valida 6 dígitos, llama al gateway). Reciben el gateway por parámetro.
- **infrastructure**: `supabaseAuthGateway` sobre `supabase.auth` (`signInWithOtp`, `verifyOtp` tipo sms, `getSession`, `onAuthStateChange`); traduce errores de Supabase a errores de dominio.
- **ui**: hook `useSession` (sesión + cargando, vía gateway) y hooks de formulario `usePhoneForm` / `useCodeForm` (estado, error traducido, cuenta regresiva). Sin reglas en componentes.
- **index.ts**: exporta hooks, casos de uso y tipos públicos.

## Servicios
- `src/services/supabase.ts`: cliente único con `EXPO_PUBLIC_SUPABASE_URL`/`PUBLISHABLE_KEY`, `storage` AsyncStorage, `persistSession`, `autoRefreshToken`, `detectSessionInUrl: false`. Falla claro si faltan las variables.

## Pantallas (`app/(auth)`)
- `sign-in.tsx` (A01): título, subtítulo, `TextField` con prefijo `+506`, botón "Recibir código por WhatsApp", texto legal. Navega a `verify` con el teléfono normalizado.
- `verify.tsx` (A02/A03): encabezado con volver, texto con el número, `TextField` 6 dígitos (error de A03), botón "Verificar", "Reenviar código en mm:ss" → "Solicitar otro código", "Cambiar número".
- `app/index.tsx` y `(auth)/_layout.tsx`: con sesión → `/children`; sin sesión → `/sign-in`.

## Pruebas
- Unitarias de domain/application con gateway falso y reloj inyectado.
- Gateway Supabase con cliente simulado (mapeo de errores).
- Pantallas con `expo-router/testing-library` + gateway falso: flujo feliz, número inválido, código incorrecto, reenviar bloqueado < 60 s, redirección con sesión.
- AsyncStorage con el mock oficial del paquete en `jest`.

## Riesgos
- Variables de entorno ausentes en tests/CI → el cliente se crea perezoso y los tests inyectan el gateway.
- `verifyOtp` exige el mismo formato de teléfono que `signInWithOtp` → usar siempre el normalizado.
