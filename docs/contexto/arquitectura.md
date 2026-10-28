# Arquitectura — [NOMBRE_PRODUCTO]

> Leyenda: **[IMPL]** existe en el repo · **[PLAN]** solo en `docs/arquitectura-sistema.md` o decisión de socios.
> Fuente de verdad del diseño: `docs/arquitectura-sistema.md` (24 oct 2026). Del esquema: `supabase/migrations/` (aún no existe).

## Estado

Fase 0. Solo hay entorno de desarrollo (ticket `RIDY-0001`). **Cero código de producto, cero tablas, cero tests.**

## Stack

| Capa | Herramienta | Estado |
|---|---|---|
| Gestor de paquetes | pnpm `11.1.3` (`packageManager`), Node `>=22`, npm bloqueado | [IMPL] |
| BD local | Supabase CLI `^2.121.0` (lock `2.121.0`), Postgres 17 en Docker Desktop | [IMPL] |
| Cliente Supabase | `@supabase/supabase-js` `^2.118.0`, `@supabase/ssr` `^0.12.7` | [IMPL] instaladas, sin uso |
| App móvil | Expo + React Native + TypeScript, Expo Router, una app con todos los roles | [PLAN] |
| Estado/datos | TanStack Query + cliente Supabase | [PLAN] (README) |
| GPS / mapas | `expo-location` + `expo-task-manager`, `react-native-maps` | [PLAN] (README) |
| Backend | Supabase: Postgres + PostGIS, Auth OTP, Realtime, Edge Functions, RLS, pg_cron | [PLAN] |
| Push | Expo Notifications desde Edge Function | [PLAN] |
| Web pública | Landing + directorio de transportistas | [PLAN] — framework sin elegir |
| Errores / CI | Sentry; GitHub Actions (typecheck, lint, `test-rls`, build) | [PLAN] |

Versiones de libs futuras: [PENDIENTE: fijar al instalarlas; hoy no están en `package.json`].

## Mapa de carpetas

```
.                         [IMPL]
├─ .claude/               agentes, comandos, skills de IA
├─ .github/CODEOWNERS     aprobación de un socio distinto al autor
├─ docs/
│  ├─ arquitectura-sistema.md   diseño aprobado
│  ├─ constitution.md           reglas no negociables
│  ├─ specs/RIDY-0001-…, RIDY-0002-…
│  └─ contexto/                 estos docs
├─ supabase/config.toml, seed.sql (vacío)
├─ package.json, pnpm-lock.yaml, .npmrc, .env.example
└─ README.md
```

[PLAN] monorepo: `apps/mobile/` (rutas `(auth)`, `(parent)`, `(driver)`, `(manage)`; `src/features|components|services|theme|i18n`), `apps/web/` (web pública), `packages/shared/` (tipos Supabase, zod), `supabase/migrations|functions|tests/`, `.github/workflows/ci.yml`.
Sin `apps/admin/`: la administración vive en la app (D9). [PENDIENTE: framework de `apps/web/`].

## Flujo de datos [PLAN]

1. Apps hablan **solo con Supabase**; Supabase habla con servicios externos (push, OTP).
2. Teléfono del chofer = fuente de verdad en ruta:
   - Posición cada 5–10 s → Realtime Broadcast privado `trip:<id>` (solo encargados del viaje).
   - Muestra cada 30–60 s → `location_pings` (particionada por mes, purga 30 días).
   - Geocercas calculadas en el teléfono → **un evento** al cruzar umbral → Edge Function.
3. Edge Function guarda en `attendance` / `trip_events`, revisa `notifications_log` (no duplicar) y manda push.
4. Cada madrugada se crean `trips` desde plantillas `routes`, saltando `calendar_days`.
5. Permisos: la app pregunta a la BD (RLS + funciones SQL); nunca decide sola.

## Qué NO existe todavía

- `apps/`, `packages/`, `pnpm-workspace.yaml` (no es monorepo aún).
- `supabase/migrations/`, `supabase/functions/`, `supabase/tests/`.
- `.github/workflows/` (sin CI).
- Runner de tests, linter, typecheck, script `pnpm validate` (los agentes lo citan; no existe).
- `AGENTS.md` real (contiene solo `### TODO PATRICK`).
- Proveedor de OTP: `auth.sms` y Twilio desactivados en `config.toml`.
- Entorno cloud / producción.
