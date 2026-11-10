# ATDE-13 — Plan

## Referencias
`docs/constitution.md` §2, §5, §6 · `docs/arquitectura-sistema.md` (Estructura del repo) · `docs/adr/0001-capas-y-runner.md` · `.github/workflows/ci.yml` (ATDE-12).

## Enfoque
Paquete de workspace `@ridy/shared` (ya cubierto por `packages/*` en `pnpm-workspace.yaml`) que exporta TypeScript fuente desde `src/index.ts`. Sin paso de build: menos piezas y Metro/jest ya transforman TS.

## Módulos
1. **`packages/shared/`** — `package.json` (`@ridy/shared`, privado, `main`/`types` a `src/index.ts`, dep `zod`, scripts `typecheck` y `test`), `tsconfig.json` estricto propio.
2. **Teléfono** — `src/phone.ts`: esquema zod que recorta, quita separadores, exige E.164 y devuelve el número normalizado con `+`; exporta también el tipo inferido. Test `src/phone.test.ts`.
3. **Tipos de BD** — `src/database.types.ts` generado por el CLI de Supabase contra la BD local; nunca se edita a mano. Script de raíz `db:types` lo regenera. `src/index.ts` reexporta `Database` y el esquema de teléfono.
4. **Consumo en mobile** — `apps/mobile` declara `@ridy/shared` como `workspace:*`; un test en mobile importa esquema y tipo por el nombre del paquete (prueba que la resolución funciona en jest y en `tsc`).
5. **CI** — en `test-rls`, tras `pnpm test:db`: regenerar tipos y fallar si `git diff` muestra cambios en el archivo generado.
6. **Docs** — constitución §2 (zod), `docs/contexto/arquitectura.md` marca `packages/shared` [IMPL], README/flujo menciona correr `pnpm db:types` tras cada migración.

## Decisiones de diseño
- Runner del test de shared: jest (el de la constitución). Si `jest-expo` no aplica fuera de RN, el test se ejecuta desde la config jest de mobile (raíz extra) sin agregar deps; coder elige la opción que funcione y la anota en `task.md`.
- Archivo generado excluido de lint y formateo; fin de línea LF para que el diff de CI no dé falso positivo en Windows.
- Normalizar el teléfono en el propio esquema (transform) para que todos los límites guarden el mismo formato.

## Riesgos
- Diferencias de salida entre versiones del CLI → el CLI está fijado como devDependency.
- Metro en monorepo pnpm: Expo SDK 58 lo resuelve solo; se verifica con `expo export`.
