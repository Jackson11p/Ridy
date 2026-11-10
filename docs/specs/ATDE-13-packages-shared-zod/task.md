# ATDE-13 — Tareas

- [x] ATDE-13-T01 Spec, plan y tareas
- [x] ATDE-13-T02 `packages/shared` (`@ridy/shared`, tsconfig, scripts) + `zod` ^4 + `src/phone.ts` con TDD (`src/phone.test.ts`: válidos, inválidos, normaliza a `+` dígitos); `pnpm test` lo corre; zod en constitución §2
  - Rojo: jest `Cannot find module './phone'`. Verde: 15 casos PASS; `pnpm test` 9 suites/53 PASS. Runner: `roots` de la config jest de `apps/mobile` incluye `packages/shared/src` (jest-expo transforma el TS; shared sin jest propio).
- [x] ATDE-13-T03 Script raíz `db:types` → `packages/shared/src/database.types.ts` (LF, sin lint); `src/index.ts` exporta `Database` y teléfono (depende de T02)
  - Rojo: `src/index.test.ts` → jest `Cannot find module './index'` y tsc TS2307. Verde: `pnpm db:types` genera el archivo (LF vía `.gitattributes`), 2 suites/16 PASS en shared, typecheck OK. Lint: ningún linter cubre `packages/shared` hoy (eslint solo en mobile), así que no hace falta exclusión.
- [x] ATDE-13-T04 `apps/mobile` depende de `@ridy/shared` (`workspace:*`); test en mobile importa esquema y `Database` por nombre de paquete; `tsc` y `expo export --platform android` verdes (depende de T03)
  - Rojo: `__tests__/shared.test.ts` → jest `Cannot find module '@ridy/shared'` y tsc TS2307. Verde: typecheck/lint OK, `pnpm test` 11 suites/55 PASS, `expo export --platform android` OK (también con un import temporal de `@ridy/shared` en `app/_layout.tsx`, revertido: Metro resuelve el paquete).
- [x] ATDE-13-T05 CI: en `test-rls` regenerar tipos y `git diff --exit-code` del archivo generado; probar local que un cambio sin regenerar falla (depende de T03)
  - Rojo: archivo generado alterado y en índice (`plate: number`) → `pnpm db:types` + `git diff --exit-code` sale 1. Verde: restaurado → mismo par sale 0. Paso añadido tras `pnpm test:db` en `test-rls`.
- [x] ATDE-13-T06 Docs: `arquitectura.md` `packages/shared` [IMPL], instrucción `pnpm db:types` tras cada migración en `docs/contexto/flujo-de-trabajo.md` o `convenciones.md`
  - Solo docs (sin prueba): `arquitectura.md` [IMPL] `packages/shared`; `flujo-de-trabajo.md` paso BD + fila `test-rls`; README fila `db:types`.
- [x] ATDE-13-T07 `pnpm typecheck`, `pnpm lint`, `pnpm test`, `pnpm test:db` verdes
  - Verificación (sin prueba nueva): typecheck (shared + mobile) y lint OK; `pnpm test` 11 suites/55 PASS; `pnpm test:db` 13 archivos/221 PASS; `pnpm db:types` sin diff.

## Correcciones de review
- [x] ATDE-13-T08 Docs: plan alineado (shared sin script `test`, tests vía `roots` de mobile); `convenciones.md` exime archivos generados de 150 líneas y lint
  - Solo docs. Resto de hallazgos de reviwer = mejoras sin acción (sin bloqueantes).
