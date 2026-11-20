# Plan — RIDY-0004

## Referencias
- Agentes actuales: `.claude/agents/{planner,coder,reviwer}.md`.
- Comando: `.claude/commands/nueva-feature.md`. Flujo: `Claude.md`, `docs/contexto/flujo-de-trabajo.md`.
- Runners: ADR-0001 (`jest-expo`, pgTAP en `supabase/tests/`).

## Agente `test-adversarial`
- Frontmatter como el resto: nombre, descripción con ejemplos, modelo Opus, color propio. Herramientas: lectura, Bash, escritura (solo en su territorio).
- Contexto limpio: el orquestador le pasa solo carpeta de spec y rango de commits. Primero arma la lista de ataques desde `spec.md`, constitución y diff de producción; recién después lee las pruebas de coder para no repetirlas.
- Territorio: crea solo archivos de prueba propios con sufijo `.adversarial.test` (`supabase/tests/<tema>.adversarial.test.sql`, `apps/mobile/**/<x>.adversarial.test.ts(x)`), así no choca con coder y el runner los toma sin config.
- Catálogo de ataques: otra empresa, otra familia, `anon`, rol sin membresía o perfil inactivo, filas inactivas, columnas no concedidas, bypass vía FK o función `security definer`, valores límite y nulos, ubicación de menores fuera de ruta activa, entradas inválidas en límites de capa.
- Resultado: pruebas que pasan → un commit `test(<ámbito>): TICKET adversariales`. Pruebas que fallan → no se commitean; van como hallazgo con el reproductor exacto y la salida.
- Prohibido: editar producción, `docs/specs/`, pruebas de coder; push; BD remota.

## Integración
- `Claude.md`: título de sección con los cuatro agentes y regla: test-adversarial obligatorio al usar agentes, tras APROBADO de reviwer, con contexto limpio; spec cerrada solo con veredicto SIN HALLAZGOS.
- planner: ciclo y descripción con el paso 4; recibe hallazgos de test-adversarial igual que los de reviwer.
- reviwer: al aprobar, el siguiente paso es test-adversarial. coder: descripción con la secuencia nueva.
- `/nueva-feature` paso 3: secuencia de cuatro y columna "adversarial" en la tabla final.
- `flujo-de-trabajo.md`: paso 5 y checklist con test-adversarial.

## Verificación
- Frontmatter parseable (mismos campos que los otros agentes); referencias cruzadas por grep; `Claude.md` < 200 líneas; `git diff --check`.
