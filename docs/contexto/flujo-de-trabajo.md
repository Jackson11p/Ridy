# Flujo de trabajo — [NOMBRE_PRODUCTO]

> Leyenda: **[IMPL]** funciona hoy · **[PLAN]** escrito, sin herramienta que lo soporte aún.

## Preparar entorno [IMPL]

```powershell
corepack enable
pnpm install
pnpm db:start                      # Docker Desktop abierto, backend WSL2
pnpm db:reset                      # migraciones + seed
Copy-Item .env.example .env.local  # pegar Publishable key de `pnpm db:status`
```

Studio: http://127.0.0.1:54323 · API: http://127.0.0.1:54321 · Mailpit: http://127.0.0.1:54324.
Tras `git pull` con migraciones nuevas → `pnpm db:reset`.

## Pasos para hacer un cambio

1. **Ticket**: tomar número `RIDY-NNNN`. [PENDIENTE: dónde viven los tickets (GitHub Issues, otro)]
2. **Spec**: `docs/specs/RIDY-NNNN-nombre/spec.md` (qué, 10–30 líneas). [IMPL]
3. **Plan**: `plan.md` (cómo, 20–50 líneas, sin código). [IMPL]
4. **Tareas**: `task.md` con `- [ ] RIDY-NNNN-Tnn …`. [IMPL]
5. **Agentes**: solo si el dev lo pide. Grande (varias capas, reglas de negocio, 4+ tareas) → `planner` → `coder` → `reviwer`. Pequeño → directo. [IMPL]
6. **Rama**: [PENDIENTE: convención de ramas; hoy todo va directo a `main`]
7. **Por tarea**: test rojo → cambio mínimo → verde → refactor → marcar `[x]` → un commit `<tipo>(<ámbito>): RIDY-NNNN-Tnn <desc>`. [PLAN: no hay runner]
8. **BD**: `pnpm db:migration <nombre>` → escribir SQL con RLS + prueba RLS → `pnpm db:reset`. Si se tocó Studio: `pnpm db:diff <nombre>`. [IMPL scripts; PLAN pruebas]
9. **PR**: revisión de un socio distinto al autor (`CODEOWNERS`). [IMPL archivo; PENDIENTE: protección de rama]

## Checklist de "terminado"

- [ ] Spec, plan y task existen; todas las tareas en `[x]`.
- [ ] Criterios de aceptación de la spec verificados (con evidencia).
- [ ] Tests en verde; bug fix incluye test que lo reproduce. [PENDIENTE: comando, `pnpm validate` no existe]
- [ ] Tabla nueva → RLS activado + prueba RLS.
- [ ] Escrituras sensibles por función SQL.
- [ ] Sin secretos ni `service_role` en código; `.env.local` sin subir.
- [ ] Sin `any`, `@ts-ignore`, `eslint-disable`.
- [ ] Archivos < 150 líneas, funciones < 30.
- [ ] Textos de UI en i18n (es/en).
- [ ] Datos de niños mínimos (sin fotos, sin fecha de nacimiento, sin cédula).
- [ ] Docs afectados actualizados (`docs/arquitectura-sistema.md`, `docs/contexto/`).
- [ ] Revisión aprobada por el otro socio (y `reviwer` si se usaron agentes).

## CI [PLAN]

`.github/workflows/ci.yml`: typecheck · lint · `test-rls` · build. No existe todavía.

## Deploy

- **BD**: solo local. [PENDIENTE: proyecto Supabase cloud, cómo se aplican migraciones a prod (`supabase db push`?), quién lo hace]
- **Edge Functions**: [PENDIENTE: proceso de deploy]
- **App móvil**: [PENDIENTE: EAS Build / tiendas, canales beta]
- **Web pública**: [PENDIENTE: hosting]
- **Secretos prod**: [PENDIENTE: dónde viven]

## Fases [PLAN]

Fase 0 actual. Orden en fase 0–1: migración inicial con RLS → login por teléfono y selector de vista → alta del transportista → invitación de padres → viajes diarios + ubicación + Abordó/No salió → push → "Hoy no va" → prueba real con una buseta.
Condición de salida de cada fase: [PENDIENTE: el diagrama de fases está embebido y no se exportó al `.md`].
