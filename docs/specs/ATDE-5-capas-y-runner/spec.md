# ATDE-5 — Decidir capas del código y runner de tests (ADR)

## Problema

La constitución deja capas (§4) y runner de tests (§5) como `[POR DEFINIR]`. La arquitectura propone `src/features|components|services`; los agentes asumen `src/modules/<m>/domain|application|infrastructure|ui`. Sin una sola convención, ATDE-6 (esqueleto Expo) y todo el código siguiente no pueden empezar con TDD.

## Objetivo

Una sola estructura de capas y un runner JS + SQL/RLS elegidos, escritos en un ADR corto y reflejados en constitución y `docs/contexto/`.

## Criterios de aceptación

1. ADR en `docs/adr/` con capas elegidas, runner elegido y lo descartado con su porqué.
2. Constitución §4 y §5 sin `[POR DEFINIR]` de capas ni runner.
3. `docs/contexto/convenciones.md` sin los `[PENDIENTE]` de capas y runner; `decisiones.md` y `arquitectura.md` coherentes.
4. Agentes (`planner`, `coder`, `reviwer`, `refactorizador`, `react-doctor`) apuntan a las capas y comandos del ADR; ninguno cita `AGENTS.md`, `src/modules/`, shadcn ni `pnpm validate` (pedido de socios, sin ticket aparte).
5. Aprobado por ambos socios en PR (fuera de este trabajo: no se hace push).

## Fuera de alcance

- Instalar deps o crear `apps/mobile` (ATDE-6).
- Framework web, proveedor OTP.

## Supuestos

- Ticket Jira `ATDE-5`; carpeta `docs/specs/ATDE-5-capas-y-runner/`, tareas `ATDE-5-Tnn`.
- El ticket existe para decidir este `[POR DEFINIR]`: el ADR queda **Propuesto** y rige recién al aprobarse el PR por ambos socios (criterio 4).
- Criterio conservador: reusar nombres ya escritos (`features/` de la arquitectura, `domain|application|infrastructure|ui` de los agentes) y lo estándar de cada herramienta (preset oficial de Expo, pgTAP del CLI ya instalado).
- Solo docs: sin código ni runner instalado aún → verificación por grep (como RIDY-0002), no tsc/lint/tests.
