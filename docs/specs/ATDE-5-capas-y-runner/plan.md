# ATDE-5 — Plan

## Decisión de capas

- `apps/mobile/src/features/<feature>/` con cuatro carpetas internas:
  - `domain/` — tipos, reglas puras y contratos de I/O. Sin imports de RN, Expo ni Supabase.
  - `application/` — casos de uso; dependen solo de `domain`.
  - `infrastructure/` — implementan los contratos (Supabase, GPS, push).
  - `ui/` — componentes y hooks TanStack Query del feature; sin reglas de negocio.
  - `index.ts` — API pública; otros features y `app/` importan solo de ahí.
- Fuera de features: `app/` (Expo Router, solo pantallas que componen features), `src/components/` (visuales genéricos, solo props), `src/services/` (cliente Supabase único y env), `src/theme/`, `src/i18n/`.
- Dependencias hacia dentro: `ui → application → domain`; `infrastructure` implementa lo que declara `domain`.
- Por qué: cumple §4 (I/O tras contratos, cero negocio en UI) y reusa `features/` de la arquitectura y los nombres de capas de los agentes.

## Decisión de runner

- JS/TS: `jest-expo` + `@testing-library/react-native` (preset oficial de Expo). Se instalan en ATDE-6.
- SQL/RLS: pgTAP vía `supabase test db` (ya en el CLI instalado), archivos en `supabase/tests/*.test.sql`; RLS se prueba fijando rol y `request.jwt.claims`.

## Descartado

- `src/features|components|services` plano: mezcla I/O y reglas dentro del feature.
- `src/modules/`: mismo modelo, otro nombre; los docs ya dicen `features/`.
- Vitest: sin preset oficial para React Native. Jest sin preset: transformaciones RN a mano.
- RLS desde JS contra Supabase local: más lento y requiere crear usuarios de Auth.

## Archivos

1. `docs/adr/0001-capas-y-runner.md` (nuevo).
2. `docs/constitution.md` §4, §5.
3. `docs/contexto/convenciones.md`, `decisiones.md`, `arquitectura.md`; árbol de `docs/arquitectura-sistema.md`.

## Verificación

- Grep `POR DEFINIR` en constitución: no aparecen capas ni runner.
- Grep `PENDIENTE` en convenciones: no aparecen capas ni runner.
