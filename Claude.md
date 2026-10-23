# Claude.md

## Flujo de trabajo obligatorio

No se genera código, tickets ni tareas sin una spec. Las specs viven en `docs/specs/TICKET-nombre/`, donde `TICKET` es el número del ticket (p. ej. `docs/specs/RIDY-42-login/`). Así dos devs en paralelo nunca chocan de número. Las tareas se identifican como `TICKET-Tnn` (p. ej. `RIDY-42-T01`).

1. **Leer** el ticket o la tarea por hacer.
2. **Crear la spec**: `docs/specs/TICKET-nombre/spec.md`.
3. **Crear el plan**: leer `spec.md` y escribir `plan.md` en la misma carpeta.
4. **Crear las tareas**: leer `spec.md` y `plan.md` y escribir `task.md` con las tareas por hacer como checkboxes (`- [ ]`). Cada tarea se marca `- [x]` al completarse.

**Longitud** (al grano, sin relleno):

| Archivo | Líneas | Enfoque |
|---|---|---|
| `spec.md` | 10–30 | El **qué**: objetivo de negocio, requisitos de usuario, restricciones críticas, criterios de aceptación. Sin detalles técnicos. |
| `plan.md` | 20–50 | El **cómo**: arquitectura y decisiones de diseño en módulos independientes. Sin código. |
| `task.md` | Máx. 100 | La **ejecución**: lista secuencial de tareas atómicas y testeables. Cada tarea 1–2 líneas. |

- **< 10 líneas** → ambiguo, la IA adivina. Añadir restricciones.
- **> 50 líneas** (spec o plan) o **> 100** (task) → sobre-especificado. Partir la feature en sub-features con su propia carpeta.

Ningún paso empieza sin que el anterior exista. Si falta la spec, se crea antes de cualquier otra cosa.

## Agentes (`planner` → `coder` → `reviwer`)

- **Tareas pequeñas:** no hace falta usar los agentes. Se sigue el flujo de spec, pero se trabaja directamente.
- **Tareas grandes y complejas:** se recomienda la secuencia `planner` → `coder` → `reviwer`. Criterios: toca varias capas o módulos, cambia reglas de negocio, o sale en 4+ tareas (detalle en `.claude/agents/planner.md` → *Cuándo se usa*).
- **Quién decide:** el dev indica en su prompt si quiere usar los agentes o no. Si no lo dice, no se lanzan.
