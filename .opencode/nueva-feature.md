# Nueva feature — adaptación para OpenCode

Lee y ejecuta `.claude/commands/nueva-feature.md` usando como `$ARGUMENTS`
el pedido que recibiste al invocar el comando. Lee antes `docs/constitution.md`
y `Claude.md`. Este archivo adapta herramientas; no cambia el alcance del pedido.

## Equivalencias de ejecución

- El agente principal coordina todo el flujo hasta completar implementación y revisión.
- Carga la skill `orchestration` para la investigación con un worker Codex de solo lectura;
  sigue su protocolo y libera el worker al terminar. Si sus herramientas o Codex no están
  disponibles, usa `task` con `subagent_type: explore`, exclusivamente para investigar,
  con el mismo alcance y reporte de máximo 40 líneas. Informa el reemplazo; no inventes resultados.
- Para GRANDE, usa `task` con los subagentes `planner`, `coder` y `reviwer` registrados
  en `.opencode/agents/`. No interpretes `@planner` como una herramienta de Claude.
- El coordinador invoca planner para planificar, coder para implementar y reviwer para
  revisar; devuelve los hallazgos a planner y repite hasta resolver los bloqueantes.
  Entrega a cada subagente el pedido, la carpeta de spec, las tareas, los commits,
  los reportes previos pertinentes y estas reglas de adaptación.
- Para CHICA, trabaja directamente después de investigar y crear spec, plan y tareas.
- Los roles heredan el modelo configurado en OpenCode. Los alias `opus` y `sonnet`
  de los archivos Claude no son identificadores de modelo válidos de OpenCode.
  Si la sesión permite seleccionar modelos equivalentes configurados, conserva la
  preferencia original y la revisión reforzada para migraciones, RLS, Auth o GPS de menores.
  En otro caso, informa el modelo heredado y conserva la revisión especializada de esas áreas.
- `Skill` significa la herramienta `skill`; las consultas al usuario usan `question`.
- La autorización del comando permite delegar y hacer un commit por tarea al ejecutarlo.
  Antes de cada commit revisa status, diff e historial y agrega solo los archivos de la tarea.
  Nunca incluyas trabajo ajeno ni secretos. Nunca hagas push ni cambios en Supabase remoto.

## Autonomía y precedencia

En este comando, el paso de preguntas generales del planner se reemplaza por supuestos
conservadores documentados en `spec.md`. Pregunta únicamente en los casos de detención
del comando original (constitución, decisiones pendientes, dependencias, API de pago,
fuera del MVP o borrado de datos). La constitución siempre prevalece.

El coordinador mantiene las delegaciones: coder devuelve los commits para que el
coordinador lance reviwer, y planner devuelve las tareas listas para coder.
No dupliques la revisión ni inicies ciclos anidados de subagentes.

Usa los scripts reales del proyecto para tsc, lint y tests; si `pnpm validate` no
existe, ejecuta sus comprobaciones equivalentes disponibles y reporta cualquier bloqueo.
No declares checks ni revisiones aprobados sin evidencia. Al terminar entrega los
supuestos y una tabla por tarea con commit, revisión y estado.
