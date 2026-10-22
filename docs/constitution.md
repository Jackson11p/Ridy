# Constitución del proyecto Ridy

Reglas no negociables. Todo agente (`planner`, `coder`, `reviwer`) y toda persona las lee antes de planear o tocar código. Si una spec choca con este doc, gana este doc; cambiarlo requiere acuerdo explícito del usuario.

> `[POR DEFINIR]` = hueco que decide el usuario. Ningún agente lo rellena suponiendo: pregunta.

## 1. Problema y de qué va el proyecto

- **Problema:** [POR DEFINIR — qué dolor resuelve, en 1-2 frases]
- **Usuario objetivo:** [POR DEFINIR]
- **Qué hace (MVP):** [POR DEFINIR — 3-5 capacidades]
- **Qué NO hace:** [POR DEFINIR — fuera de alcance explícito]

Regla: toda feature nueva se justifica contra este problema. Si no encaja → fase posterior (`/scope`).

## 2. Stack simple

- **Stack:** [POR DEFINIR — lenguaje, framework, BD, hosting]
- Mínimas dependencias. Antes de añadir una: ¿lo resuelve stdlib, plataforma o una dep ya instalada? Si sí → no se añade.
- Nueva dependencia o cambio de stack = decisión del usuario, anotada aquí.

## 3. Relación entre spec y código

- Ningún código sin spec. Flujo: `docs/specs/TICKET-nombre/spec.md` → `plan.md` → `task.md` (escribe `planner`).
- `spec.md`: problema, objetivo, criterios de aceptación verificables, fuera de alcance, dudas.
- Cada tarea de `task.md` = un test + cambio mínimo = un commit (`coder`).
- Código y spec no divergen: si al implementar algo no encaja, se para y se actualiza la spec primero (vía `planner`).
- `reviwer` verifica cada commit contra su spec.

## 4. Separación de capas

Por módulo en `src/modules/<modulo>/`:

| Capa | Contiene | Depende de |
|------|----------|-----------|
| `domain` | entidades, value objects, invariantes, reglas de negocio | nada |
| `application` | casos de uso | `domain` |
| `infrastructure` | I/O: BD, APIs, env, reloj, storage; implementa contratos | `domain`, `application` |
| `ui` | componentes, hooks | `application` |

- Dirección única: `ui → application → domain`. `domain` no importa nada externo.
- API pública del módulo solo por `index.ts`; nadie importa archivos internos de otro módulo.
- Cero lógica de negocio en componentes visuales.
- Archivos < 150 líneas, funciones < 30.

## 5. Pruebas obligatorias (TDD)

- Rojo → verde → refactor. Test primero, siempre; falla por la razón correcta antes de escribir código.
- Sin test no hay commit. Bug fix empieza con test que lo reproduce.
- `domain` y `application` con tests unitarios; `infrastructure` con tests de integración donde haya I/O real.
- Herramienta de tests: [POR DEFINIR según stack]
- Suite completa en verde antes de cerrar tarea.

## 6. Datos persistentes

- **Almacenamiento:** [POR DEFINIR — BD/servicio]
- Esquema cambia solo por migraciones versionadas en repo; nunca a mano en prod.
- Acceso a datos solo desde `infrastructure`, detrás de un contrato (repositorio) definido en `domain`/`application`.
- Validar datos en cada límite (entrada de usuario, API, BD).
- Secretos en variables de entorno, nunca en repo.

## 7. Idioma consistente

- Docs, specs, commits, comentarios y textos de UI: **español**.
- Código (variables, funciones, tipos, archivos): [POR DEFINIR — inglés o español; uno solo, sin mezclar]
- Lenguaje ubicuo: términos de negocio iguales en spec, código y UI. Glosario en cada `spec.md`.
