---
description: Busca en el codebase si ya existe lo que querés implementar antes de crear código nuevo.
argument-hint: qué querés implementar (ej: "servicio para listar rutas", "función SQL para aprobar solicitud")
---

Antes de implementar `$ARGUMENTS`, buscá si ya existe en el codebase. Estructura según `docs/arquitectura-sistema.md` → "Estructura del repo" (si una carpeta aún no existe, decilo y seguí).

## Búsqueda

1. `apps/mobile/src/services/` — acceso a Supabase (consultas y RPC).
2. `apps/mobile/src/features/` — lógica por feature (location, geofence, attendance, invites…).
3. `apps/mobile/src/components/` — componentes similares.
4. `packages/shared/` — tipos generados de Supabase, validaciones zod, utilidades.
5. `supabase/migrations/` — tablas, políticas RLS y funciones SQL; `supabase/functions/` — Edge Functions.

## Salida requerida

Responder en este formato exacto:

### ¿Ya existe?

| Qué | Dónde | Estado |
|-----|-------|--------|
| [cosa encontrada] | [archivo:línea] | ✅ Existe / ⚠️ Parcial / ❌ No existe |

### Recomendación

- **Si existe:** usá `[nombre]` de `[archivo]`. No crear nada nuevo.
- **Si es parcial:** extender `[nombre]` agregando `[qué]`. No duplicar.
- **Si no existe:** recién ahora crear, en la carpeta que corresponda de la lista de arriba.

### Convenciones a respetar si creás algo nuevo

- Ver `docs/contexto/convenciones.md`.
- Permisos en la BD (RLS + funciones SQL), nunca en la app.
- Cambio de BD = migración nueva con RLS y prueba RLS.
