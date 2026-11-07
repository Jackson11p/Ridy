# ATDE-12 — CI en GitHub Actions

## Problema

Todo cambio entra por PR con revisión del otro socio (CODEOWNERS), pero no hay CI: un PR puede romper tipos, lint, RLS o el build sin que el revisor lo vea.

## Objetivo

Cada PR a `main` corre automáticamente typecheck, lint, pruebas RLS y build; solo se mergea en verde.

## Criterios de aceptación

1. `.github/workflows/ci.yml` corre en cada PR a `main`.
2. Jobs separados: `typecheck`, `lint`, `test-rls` (Supabase local en el runner) y `build`.
3. Protección de rama: `main` exige los 4 jobs en verde y revisión del otro socio (CODEOWNERS).
4. Ningún secreto en el workflow; `service_role` nunca en el repo.

## Fuera de alcance

- Deploy (EAS, Supabase cloud, Edge Functions), caché avanzada, matrices de versiones.

## Supuestos

- Ticket Jira `ATDE-12`; rama y carpeta `ATDE-12-ci-github-actions`; tareas `ATDE-12-Tnn`.
- "Build" = bundle JS de la app con `expo export --platform android` (sin EAS ni toolchain nativo, sin secretos).
- Sin deps nuevas: actions oficiales (`checkout`, `setup-node`) + `pnpm/action-setup`; Supabase CLI ya es devDependency.
- `pnpm test` (jest) no lo pide el ticket; queda fuera para no ampliar alcance.
- Criterio 3 es configuración de GitHub (remoto): Claude no la aplica; se documenta el comando para que el dueño del repo la active tras mergear (los checks deben existir antes).
- "Test" del workflow = correr localmente sobre checkout limpio los mismos comandos de cada job.
