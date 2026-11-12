# Arquitectura — [NOMBRE_PRODUCTO]

> Leyenda: **[IMPL]** existe en el repo · **[PLAN]** solo en `docs/arquitectura-sistema.md` o decisión de socios.
> Fuente de verdad del diseño: `docs/arquitectura-sistema.md` (24 oct 2026). Del esquema: `supabase/migrations/` (aún no existe).

## Estado

Fase 0. Entorno de desarrollo (`RIDY-0001`) + esqueleto `apps/mobile` sin features (ATDE-6). **Cero tablas, cero lógica de negocio.**

## Stack

| Capa | Herramienta | Estado |
|---|---|---|
| Gestor de paquetes | pnpm `11.1.3` (`packageManager`), Node `>=22`, npm bloqueado | [IMPL] |
| BD local | Supabase CLI `^2.121.0` (lock `2.121.0`), Postgres 17 en Docker Desktop | [IMPL] |
| Cliente Supabase | `@supabase/supabase-js` `^2.118.0`, `@supabase/ssr` `^0.12.7` | [IMPL] instaladas, sin uso |
| App móvil | Expo SDK 58 + RN 0.88 + TS 6 estricto, Expo Router, una app con todos los roles | [IMPL] esqueleto (ATDE-6) |
| i18n | `i18next` + `react-i18next` + `expo-localization`, es/en, respaldo `es` | [IMPL] |
| Tests / lint | `jest-expo` + RNTL 14; `eslint-config-expo` (ESLint 9) | [IMPL] |
| Estado/datos | TanStack Query + cliente Supabase | [PLAN] (README) |
| GPS / mapas | `expo-location` + `expo-task-manager`, `react-native-maps` | [PLAN] (README) |
| Backend | Supabase: Postgres + PostGIS, Auth OTP, Realtime, Edge Functions, RLS, pg_cron | [PLAN] |
| Push | Expo Notifications desde Edge Function | [PLAN] |
| Web pública | Landing + directorio de transportistas | [PLAN] — framework sin elegir |
| Errores / CI | Sentry; GitHub Actions (typecheck, lint, `test-rls`, build) | [PLAN] |

Versiones exactas: constitución §2 y `apps/mobile/package.json`. Libs futuras: se fijan al instalarlas.

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
├─ apps/mobile/           Expo: app/ rutas (auth|parent|driver|manage), src/ capas ADR-0001, .env.example
├─ packages/shared/       `@ridy/shared`: tipos Supabase generados + esquemas zod
├─ supabase/config.toml, seed.sql (vacío)
├─ package.json, pnpm-workspace.yaml, pnpm-lock.yaml, .npmrc
└─ README.md
```

[PLAN] monorepo: `apps/mobile/` (rutas `(auth)`, `(parent)`, `(driver)`, `(manage)`; `src/features/<f>/domain|application|infrastructure|ui`, `src/components|services|theme|i18n` según ADR-0001), `apps/web/` (web pública), `supabase/migrations|functions|tests/`, `.github/workflows/ci.yml`.
[IMPL] `apps/mobile/src/theme/` (tokens Figma claro/oscuro + `useTheme`) y `src/components/` (`AppText`, `Button`, `TextField`, `Screen`) — ATDE-64, D10, guía en `figma.md`.
[IMPL] `packages/shared/` (`@ridy/shared`, TS fuente sin build): `database.types.ts` generado con `pnpm db:types` (no editar) y esquemas zod (`phoneSchema`, E.164). Mobile lo importa por nombre de paquete; sus tests corren en la config jest de mobile — ATDE-13.
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

- `apps/web/`, contenido en `packages/` (ATDE-13); cliente Supabase en la app.
- `supabase/migrations/`, `supabase/functions/`, `supabase/tests/`.
- `.github/workflows/` (sin CI, ATDE-12).
- `AGENTS.md` real (contiene solo `### TODO PATRICK`).
- OTP en producción y SMS de respaldo: hoy OTP por WhatsApp solo local (hook `public.send_sms_hook` → Meta Cloud API, D8, ATDE-14).
- Entorno cloud / producción.
