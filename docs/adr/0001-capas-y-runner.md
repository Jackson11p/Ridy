# ADR-0001 — Capas del código y runner de tests

- **Estado:** Aceptado (PR #2 aprobado y mergeado, 2026-11-05). Ticket ATDE-5.
- **Fecha:** 2026-11-04

## Contexto

La constitución dejaba capas (§4) y runner (§5) como `[POR DEFINIR]`. La arquitectura proponía `src/features|components|services`; los agentes asumían `src/modules/<m>/domain|application|infrastructure|ui`. Mínimo fijo de §4: cero lógica de negocio en UI, I/O (Supabase, GPS, push) tras contratos, archivos < 150 líneas, funciones < 30.

## Decisión: capas

```
apps/mobile/
├─ app/                 Expo Router: solo pantallas que componen features
└─ src/
   ├─ features/<f>/
   │  ├─ domain/        tipos, reglas puras, contratos de I/O (sin RN, Expo ni Supabase)
   │  ├─ application/   casos de uso; dependen solo de domain
   │  ├─ infrastructure/ implementan contratos: Supabase, GPS, push
   │  ├─ ui/            componentes y hooks TanStack Query del feature; sin reglas
   │  └─ index.ts       API pública del feature
   ├─ components/       visuales genéricos, solo props
   ├─ services/         cliente Supabase único y env
   ├─ theme/  i18n/
```

- Dependencias hacia dentro: `ui → application → domain`; `infrastructure` implementa lo que declara `domain`.
- Entre features y desde `app/` se importa solo por `index.ts`.
- Un feature crea solo las carpetas que usa (YAGNI).

## Decisión: runner

- **JS/TS:** `jest-expo` + `@testing-library/react-native`. Se instalan y fijan versiones en ATDE-6.
- **SQL/RLS:** pgTAP vía `supabase test db` (incluido en el CLI ya instalado). Archivos `supabase/tests/*.test.sql`; RLS se prueba fijando `role` y `request.jwt.claims` por caso. Job CI `test-rls`.

## Descartado

| Opción | Por qué no |
|---|---|
| `src/features\|components\|services` plano | Mezcla I/O y reglas dentro del feature; no aísla contratos |
| `src/modules/<m>/…` | Mismo modelo con otro nombre; arquitectura y comandos ya dicen `features/` |
| Vitest | Sin preset oficial para React Native |
| Jest sin preset | Transformaciones de RN a mano |
| RLS probado desde JS | Más lento; requiere usuarios de Auth reales en cada prueba |

## Consecuencias

- Agentes `planner`, `coder`, `reviwer`, `refactorizador` apuntan a estas capas y a `pnpm typecheck|lint|test` (ATDE-5-T06).
- Agente y skill `react-doctor` adaptados a este ADR (ATDE-5-T05).
