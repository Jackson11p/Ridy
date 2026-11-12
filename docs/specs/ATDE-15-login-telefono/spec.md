# ATDE-15 — Iniciar sesión con teléfono y código

## Problema
Choferes, padres y transportistas no tienen cómo entrar: `(auth)/sign-in` es un placeholder. El teléfono verificado es la llave de todo (vínculos por número).

## Objetivo
Entrar con número + código OTP (WhatsApp, D8) sin contraseñas, con sesión que persiste al reabrir la app.

## Criterios de aceptación
1. Número válido → se pide el código y pasa a la pantalla de código (dev: `50670000001` entra con `123456`).
2. Número inválido → error en el campo, no se pide nada.
3. Código correcto → entra; al reabrir la app sigue dentro sin pedir código.
4. Código incorrecto o vencido → "El código no es válido o ya venció", no entra, puede pedir otro.
5. Reenviar código solo tras 60 s (cuenta regresiva visible).
6. Pantallas en `(auth)` según frames Figma A01/A02/A03, solo tema y componentes de ATDE-64; textos i18n es/en.
7. `profile` creado solo visible para su dueño (prueba RLS existente de ATDE-8 lo cubre).

## Fuera de alcance
- Botones y flujo SMS (beta), selector de vista por rol (ATDE-16), cerrar sesión, logo/imágenes, términos con enlace, OTP real por WhatsApp (bloqueado por verificación de Meta).

## Supuestos
- Ticket Jira `ATDE-15`; rama y carpeta `ATDE-15-login-telefono`; tareas `ATDE-15-Tnn`.
- Deps aprobadas por el usuario (2026-11-11): `@react-native-async-storage/async-storage` (versión que fije `expo install`) y `@supabase/supabase-js` ^2.118.0 en `apps/mobile`; se anotan en constitución §2. Sin TanStack Query (no hace falta aún).
- Prefijo fijo `+506` (beta en Costa Rica); el usuario escribe los 8 dígitos; se valida con `phoneSchema` de `@ridy/shared`.
- Código en un solo campo de 6 dígitos (como A03) en vez de 6 casillas de A02.
- Tras entrar se va a `/children` provisional; ATDE-16 decide la vista por rol. Con sesión activa, `/` y `(auth)` redirigen ahí.
