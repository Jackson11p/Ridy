# ATDE-64 — Tema base y componentes desde Figma

## Problema

El prototipo de Figma (50 pantallas, temas claro y oscuro) define cómo se ve Ridy, pero `apps/mobile` solo tiene dos colores sueltos y estilos literales. Cada historia de pantalla (ATDE-15, 18, 35, 38, 46…) reinventaría el estilo.

## Objetivo

Que toda pantalla nueva salga del mismo tema y de componentes base fieles al prototipo, en claro y oscuro según el teléfono.

## Criterios de aceptación

1. Link del prototipo anotado como decisión en `docs/contexto/decisiones.md` y MCP de Figma con scope de proyecto.
2. Tokens del prototipo en `src/theme/`: colores claro y oscuro, tipografía, espaciado, radios.
3. El tema activo sigue el modo del sistema (claro/oscuro).
4. Componentes base en `src/components/`: texto (variantes del prototipo), botón (primario, secundario, peligro, texto; deshabilitado y cargando), campo de texto (etiqueta, error, deshabilitado) y contenedor de pantalla.
5. Componentes solo reciben props y usan tokens: sin lógica de negocio ni colores o tamaños literales.
6. Pantallas actuales migradas: ninguna usa valores literales.
7. Accesibles: rol, etiqueta y estado (deshabilitado/ocupado) expuestos; área táctil ≥ 48 px.
8. Guía corta en `docs/contexto/` para pedir una pantalla a partir de un frame de Figma.

## Fuera de alcance

- Pantallas reales (cada una en su historia), íconos, alertas, navegación inferior, switch/radio.
- Fuente Inter y selector manual de tema.

## Supuestos

- Ticket Jira `ATDE-64`; rama y carpeta `ATDE-64-tema-componentes-figma`; tareas `ATDE-64-Tnn`.
- Prototipo: `https://www.figma.com/design/pFcHPqTQVk7p0DrUnNdPvU` (página claro `0:1`, oscuro `25:172`).
- Inter exige `expo-font` + archivos de fuente (dep nueva = decisión del usuario): se usa fuente del sistema con los mismos tamaños, pesos e interlineados; Inter queda [ABIERTA].
- Tokens sin variable en Figma (escala de espaciado, deshabilitado claro, alto de campo) se toman de las medidas de los frames.
- Previsualizar en navegador agregado a pedido del usuario (2026-11-10, T10): solo herramienta de desarrollo; no hay versión web de la app.
