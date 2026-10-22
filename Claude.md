# Claude.md

## Flujo de trabajo obligatorio

No se genera código, tickets ni tareas sin una spec. Las specs viven en `docs/specs/TICKET-nombre/`, donde `TICKET` es el número del ticket (p. ej. `docs/specs/RIDY-42-login/`). Así dos devs en paralelo nunca chocan de número. Las tareas se identifican como `TICKET-Tnn` (p. ej. `RIDY-42-T01`).

1. **Leer** el ticket o la tarea por hacer.
2. **Crear la spec**: `docs/specs/TICKET-nombre/spec.md`.
3. **Crear el plan**: leer `spec.md` y escribir `plan.md` en la misma carpeta.
4. **Crear las tareas**: leer `spec.md` y `plan.md` y escribir `task.md` con las tareas por hacer como checkboxes (`- [ ]`). Cada tarea se marca `- [x]` al completarse.

Ningún paso empieza sin que el anterior exista. Si falta la spec, se crea antes de cualquier otra cosa.

## Agentes (`planner` → `coder` → `reviwer`)

- **Tareas pequeñas:** no hace falta usar los agentes. Se sigue el flujo de spec, pero se trabaja directamente.
- **Tareas complejas:** se usa la secuencia `planner` → `coder` → `reviwer`.
- **Quién decide:** el dev indica en su prompt si quiere usar los agentes o no. Si no lo dice, no se lanzan.
