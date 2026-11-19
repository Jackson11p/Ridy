# RIDY-0004 — Agente test-adversarial

## Objetivo
Que un agente distinto, sin el contexto de coder, intente romper lo implementado antes de cerrar una spec. Las pruebas de coder confirman lo que coder pensó; las adversariales buscan lo que no pensó (fugas de RLS entre empresas o familias, entradas inválidas, estados límite).

## Requisitos
- Nuevo agente `test-adversarial` en `.claude/agents/`.
- Orquestación queda `planner` → `coder` → `reviwer` → `test-adversarial`.
- Contexto limpio: recibe solo carpeta de spec y commits; nunca el razonamiento ni la entrega de coder.
- Ataca desde spec, constitución y código; nunca edita código de producción, spec ni pruebas de coder.
- Prueba que rompe algo = hallazgo con reproductor para planner; las que pasan quedan como pruebas de regresión.
- Regla escrita en `Claude.md` (cuándo se usa, quién lo lanza, qué bloquea).

## Criterios de aceptación
- Existe `.claude/agents/test-adversarial.md` con frontmatter válido, territorio, proceso y formato de entrega.
- `Claude.md` describe la secuencia de cuatro agentes y la regla de test-adversarial; sigue < 200 líneas.
- planner, coder, reviwer y `/nueva-feature` nombran la secuencia nueva; ninguna spec se cierra sin veredicto de test-adversarial cuando se usan agentes.

## Fuera de alcance
- Cambiar `docs/constitution.md` (requiere acuerdo; solo nombra agentes).
- Agentes de OpenCode (`.opencode/`); se portan aparte si hace falta.
- Mutation testing o herramientas nuevas (sin deps nuevas).

## Supuestos
- Ticket `RIDY-0004` (siguiente libre); rama `RIDY-0004-agente-test-adversarial`.
- Solo aplica cuando se usan agentes (tareas grandes); tareas chicas siguen directo.
- Corre tras APROBADO de reviwer; sus hallazgos reabren el ciclo planner → coder → reviwer → test-adversarial.
- Modelo Opus: buscar huecos de seguridad necesita el modelo más fuerte.
- Cambio de configuración: se verifica estructuralmente, sin pruebas de app (precedente RIDY-0003).
