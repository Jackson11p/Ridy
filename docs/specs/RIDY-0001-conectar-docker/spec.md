# RIDY-0001 — Conectar Docker (Supabase local)

## Problema

El equipo no tiene un entorno de desarrollo común para la BD. Además, el repo se inicializó con npm (`package-lock.json`, `node_modules/`), y el proyecto debe usar únicamente pnpm.

## Objetivo

Cada dev levanta Supabase local sobre Docker Desktop con `pnpm db:start`, con el mismo schema (migraciones versionadas) y los mismos datos (seed). Como opción, el equipo puede conectarse a la instancia de un dev por LAN o Tailscale.

## Criterios de aceptación

1. Repo usa solo pnpm: existe `pnpm-lock.yaml` y no existe `package-lock.json`.
2. `package.json` declara `packageManager: pnpm@<versión>`. `npm install` falla gracias a `engines.npm` + `.npmrc` con `engine-strict=true`.
3. `supabase` CLI como devDependency; `pnpm supabase --version` responde. (Desde v2.121 el CLI no tiene postinstall, así que no hace falta `approve-builds`.)
4. Carpeta `supabase/` inicializada (`config.toml`, `seed.sql`). `migrations/` se crea con la primera `pnpm db:migration`.
5. Scripts `db:start`, `db:stop`, `db:status`, `db:reset`, `db:migration`, `db:diff` en `package.json`.
6. `pnpm db:start` levanta el stack en Docker Desktop.
7. `.gitignore` excluye `node_modules/` y `.env*` salvo `.env.example`.
8. `.env.example` con las variables Supabase apuntando al stack local.
9. README documenta el setup del dev y las 2 opciones de conexión del equipo, con aviso de seguridad.

## Fuera de alcance

- Schema de negocio (tablas reales): tickets posteriores.
- Supabase cloud / prod.
- Abrir el firewall en la máquina de cada dev (lo hace cada uno a mano, documentado).

## Glosario

- **Stack local:** contenedores Supabase (Postgres, API, Studio, Auth, Mailpit) que corren en Docker Desktop.
- **Migración:** archivo SQL versionado en `supabase/migrations/`.
- **Seed:** datos de desarrollo en `supabase/seed.sql`, aplicados con `db:reset`.

## Dudas

- Ninguna bloqueante. Decisión del usuario: pnpm como único gestor y Supabase CLI como dependencia.
