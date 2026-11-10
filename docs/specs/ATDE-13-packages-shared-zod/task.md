# ATDE-13 — Tareas

- [x] ATDE-13-T01 Spec, plan y tareas
- [x] ATDE-13-T02 `packages/shared` (`@ridy/shared`, tsconfig, scripts) + `zod` ^4 + `src/phone.ts` con TDD (`src/phone.test.ts`: válidos, inválidos, normaliza a `+` dígitos); `pnpm test` lo corre; zod en constitución §2
  - Rojo: jest `Cannot find module './phone'`. Verde: 15 casos PASS; `pnpm test` 9 suites/53 PASS. Runner: `roots` de la config jest de `apps/mobile` incluye `packages/shared/src` (jest-expo transforma el TS; shared sin jest propio).
- [ ] ATDE-13-T03 Script raíz `db:types` → `packages/shared/src/database.types.ts` (LF, sin lint); `src/index.ts` exporta `Database` y teléfono (depende de T02)
- [ ] ATDE-13-T04 `apps/mobile` depende de `@ridy/shared` (`workspace:*`); test en mobile importa esquema y `Database` por nombre de paquete; `tsc` y `expo export --platform android` verdes (depende de T03)
- [ ] ATDE-13-T05 CI: en `test-rls` regenerar tipos y `git diff --exit-code` del archivo generado; probar local que un cambio sin regenerar falla (depende de T03)
- [ ] ATDE-13-T06 Docs: `arquitectura.md` `packages/shared` [IMPL], instrucción `pnpm db:types` tras cada migración en `docs/contexto/flujo-de-trabajo.md` o `convenciones.md`
- [ ] ATDE-13-T07 `pnpm typecheck`, `pnpm lint`, `pnpm test`, `pnpm test:db` verdes
