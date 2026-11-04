# RIDY-0003 — Comando de nueva feature en OpenCode

## Objetivo
Usar en OpenCode el flujo de nueva feature que ya existe en Claude.
## Requisitos
- Publicar `/nueva-feauture` y el alias `/nueva-feature`.
- Conservar investigación, clasificación por tamaño, spec, implementación y revisión.
- Mantener las restricciones de la constitución y las decisiones reservadas al usuario.
- Disponer de los roles planner, coder y reviwer en OpenCode.
## Criterios de aceptación
- Los comandos y agentes usan el formato nativo de OpenCode.
- Las instrucciones originales de Claude siguen siendo la fuente del flujo.
- Los argumentos del comando llegan al pedido y ambos nombres ejecutan el mismo flujo.
## Supuestos
- Se hereda el modelo de la sesión para no exigir proveedores adicionales.
- Este cambio de configuración se verifica estructuralmente; no requiere pruebas de aplicación.
- No se crean commits durante la instalación del comando.
## Fuera de alcance
Cambiar la aplicación o la configuración global del usuario.
