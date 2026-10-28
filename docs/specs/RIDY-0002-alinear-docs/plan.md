# RIDY-0002 — Plan

## Referencias

- Decisiones confirmadas por los socios (prompt del 28 oct 2026).
- `docs/contexto/decisiones.md` (D1–D9) y `errores-conocidos.md`.

## Enfoque

Solo docs y config de ejemplo. Sin código de dominio → no aplica TDD; se verifica con grep.

## Cambios por archivo

| Archivo | Cambio |
|---|---|
| `docs/arquitectura-sistema.md` | Actores (sin panel web), cuentas (OTP WhatsApp + SMS), cobro B2B2C, tabla "quién ve qué" (chofer ve teléfonos), `students` sin foto, privacidad, casos especiales (cambio de dirección), estructura del repo (sin `apps/admin`, web pública), decisiones abiertas marcadas |
| `docs/constitution.md` | §1 usuarios y cobro, §2 stack (sin admin React + Vite, web pública), §6 OTP |
| `README.md` | Modelo de negocio, sección "Panel admin" → administración en la app, stack, variable de la opción B |
| `.env.example` | Prefijo `EXPO_PUBLIC_` |
| `.claude/commands/scope.md` | Reescribir para este proyecto: MVP de la constitución + fases 0–1 |
| `.claude/commands/search-first.md` | Apuntar a la estructura del repo de la arquitectura |
| `docs/contexto/*.md` | Quitar avisos de conflicto ya resueltos |

## Verificación

1. `grep` sin `NEXT_PUBLIC_`, `AgroTrace`, ni marcas de merge.
2. `grep` sin "foto opcional", "panel web del transportista", "salvo un botón de llamada".
3. Lectura cruzada de las 9 decisiones en los tres docs.

## Riesgos

- `.env.local` de cada dev sigue con `NEXT_PUBLIC_`: cada uno lo renombra a mano (es personal, no se toca).
