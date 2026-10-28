# RIDY-0002 — Alinear docs con decisiones de socios

## Problema

Los socios confirmaron decisiones (cobro, privacidad, OTP, administración) que contradicen `docs/arquitectura-sistema.md`, README y constitución. Además `.env.example` usa prefijo de Next.js y `/scope` y `/search-first` son de otro proyecto (AgroTrace).

## Objetivo

Toda la documentación cuenta la misma historia y coincide con lo decidido. Un dev nuevo no lee reglas contradictorias.

## Criterios de aceptación

1. Arquitectura, README y constitución reflejan: cobro B2B2C sin pagos en app; chofer ve teléfono de encargados; "Hoy no va" hasta iniciar ruta; cambio de dirección propuesto por padre y aprobado por transportista; sin fotos de niños; OTP por WhatsApp con SMS de respaldo; administración solo en la app y web pública (landing + directorio opcional).
2. Las decisiones abiertas ya resueltas quedan marcadas `[x]` en la arquitectura.
3. `.env.example` y README usan `EXPO_PUBLIC_` en vez de `NEXT_PUBLIC_`.
4. `/scope` y `/search-first` no citan AgroTrace; `/scope` clasifica contra el MVP de la constitución y las fases de la arquitectura.
5. `docs/contexto/` (6 docs) creado y sin contradicciones con lo anterior.

## Fuera de alcance

- Elegir capas, runner de tests, framework web o proveedor OTP.
- Quitar `@supabase/ssr` (depende del framework web).
- Corregir agentes que citan `AGENTS.md`, `src/modules/`, `pnpm validate`.

## Dudas

- Borrado de datos a pedido del encargado vs "nada se borra físicamente": lo deciden los socios.
