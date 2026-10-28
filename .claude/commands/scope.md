---
description: Clasifica una feature como MVP (fase 0–1) o fase posterior. Guard de scope del proyecto.
argument-hint: descripción de la feature o idea
---

Evalúa si `$ARGUMENTS` entra en el MVP o debe diferirse.

## Proceso

1. Leer `docs/constitution.md` §1 (MVP y lo que NO hace la beta).
2. Leer `docs/arquitectura-sistema.md` → "Plan de construcción por fases" (orden de fase 0 y 1) y "Casos especiales".
3. Leer `docs/contexto/decisiones.md` (decisiones de socios ya cerradas).
4. Clasificar y responder en formato tabla.

## Salida

| | |
|---|---|
| Feature | $ARGUMENTS |
| Fase | 0–1 (MVP) / posterior |
| Paso del plan | nº del orden de fase 0–1 o N/A |
| Veredicto | ✅ MVP / ⏳ Diferir / ⛔ Choca con una decisión |
| Razón | Una línea |

## Criterio MVP (beta, 1–2 busetas)

Está en el MVP si aparece en el MVP de la constitución o en el orden de fase 0–1, **o** es necesario para el flujo core:
> transportista da de alta su ruta → chofer inicia ruta y marca "Abordó" → padre ve la buseta en vivo y recibe avisos

Todo lo demás → diferir (ej. optimización de rutas, avisos por SMS/WhatsApp a padres sin smartphone). Si choca con una decisión cerrada (pagos en la app, fotos de niños, panel web de administración) → ⛔ y citar la decisión.
