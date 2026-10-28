---
description: Feature nueva sin human in the loop. Codex investiga; si es grande planner → coder → reviwer, si es chica directo.
argument-hint: TICKET contexto; solución
---
Pedido: $ARGUMENTS

Trabaja de punta a punta sin pedirme confirmación. Lee antes docs/constitution.md (gana sobre
cualquier spec) y Claude.md (flujo y longitudes de spec/plan/task).

Si el pedido no trae número o nombre de ticket, invéntalo: número = siguiente RIDY-nn libre en
docs/specs/ (RIDY-01 si no hay ninguno); nombre = 2–4 palabras kebab-case del pedido
(p. ej. RIDY-03-hoy-no-va). Anótalo en "Supuestos" de spec.md.

1. Usa la skill orchestration: lanza un worker Codex SOLO LECTURA que investigue el pedido y
   devuelva un reporte de máx 40 líneas con rutas reales: qué existe hoy (app Expo, panel admin,
   migraciones supabase/, tablas/RLS/RPC, Edge Functions), pantallas, hooks TanStack Query y
   contratos de I/O reutilizables, qué falta crear, riesgos contra docs/constitution.md.
   Si aún no hay código, que lo diga. Libera el worker al terminar.
2. Con el reporte clasifica el tamaño (criterio de .claude/agents/planner.md → Cuándo se usa):
   - GRANDE (varias capas o módulos, regla de negocio nueva, o 4+ tareas): actúa como @planner.
   - CHICA (lo demás): sin agentes; trabaja directo siguiendo el flujo de spec de Claude.md.
   En ambos casos NO me preguntes: decide lo que falte con el criterio más conservador y
   consistente con docs/constitution.md y README.md, y anótalo en una sección "Supuestos" de
   spec.md. Escribe spec.md → plan.md → task.md en docs/specs/<TICKET>-<nombre>/ (tareas <TICKET>-Tnn).
3. GRANDE: sigue directo con coder (Opus) → reviwer (Sonnet; Opus si la tarea toca migración,
   RLS, Auth o ubicación GPS de menores) hasta que no queden hallazgos bloqueantes.
   CHICA: implementa tú las tareas con TDD, un commit por tarea, y corre tsc, lint y tests.
4. Detente y pregúntame SOLO si el pedido obliga a:
   - romper una regla de docs/constitution.md (RLS en toda tabla, esquema solo por migraciones,
     ubicación de menores visible solo a padres de esa ruta con ruta activa, secretos fuera del repo);
   - decidir un [POR DEFINIR] de la constitución, agregar dependencia o usar API de pago;
   - implementar algo fuera del MVP de la constitución (§1), o borrar datos.
5. Nunca push, supabase db push ni cambios en Supabase remoto (MCP incluido). Al final: resumen
   con supuestos tomados y tabla por tarea (commit, review, estado).
