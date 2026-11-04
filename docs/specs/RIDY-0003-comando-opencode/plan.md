# Plan — RIDY-0003

## Referencias
- Comando original: `.claude/commands/nueva-feature.md`.
- Roles originales: `.claude/agents/{planner,coder,reviwer}.md`.
- Reglas: `docs/constitution.md` y `Claude.md`.

## Enfoque
Registrar comandos Markdown en `.opencode/commands/`.
El nombre solicitado y el nombre original comparten una fuente de instrucciones.
El comando pasa el pedido explícitamente mediante la variable de argumentos.
Un adaptador común describe las diferencias de herramientas y modelos.

## Agentes
Registrar los tres roles como subagentes nativos de OpenCode.
Cada rol lee su definición original antes de actuar.
Las adaptaciones de OpenCode prevalecen sobre sintaxis exclusiva de Claude.
El coordinador conserva el control de las delegaciones y la selección de modelos.
El revisor tiene permisos de edición denegados y shell limitado a comprobaciones.

## Verificación
Comprobar frontmatter, nombres, referencias y sustitución de argumentos.
Revisar el diff y errores de whitespace.
La carga efectiva de los comandos se realiza al reiniciar OpenCode.
