# ATDE-11 — Función SQL "mis vínculos" para decidir la vista

## Problema
Tras el login la app debe elegir vista (padre, chofer, dueño, selector o bienvenida) sin calcular permisos por su cuenta: se los pregunta a la base de datos (`docs/arquitectura-sistema.md` → "Cuentas y roles", reglas 1–5).

## Requisitos
1. Una RPC sin parámetros devuelve los vínculos de la persona autenticada: roles por empresa (membresías) e hijos (encargos).
2. Solo cuenta vínculos vigentes con el mismo criterio que ya aplica la RLS: perfil activo, membresía activa, vínculo de encargado activo con estudiante activo.
3. Cada fila trae lo justo para elegir vista: empresa (id y nombre), rol o hijo (id y nombre). Nada más del niño.

## Criterios de aceptación
- Devuelve solo vínculos de `auth.uid()`; no hay forma de pedir los de otro.
- Cubre los 5 casos: solo encargado, solo chofer, dueño, varios roles, sin vínculos (resultado vacío).
- `anon` no la ejecuta; sin usuario falla con `28000`; perfil inactivo → vacío.
- `pnpm db:reset` sin errores y `pnpm test:db` en verde; tipos regenerados en `packages/shared`.

## Fuera de alcance
- Pantallas y selector de vista (ATDE-16), hook TanStack Query, invitaciones/aceptación (ATDE-27).

## Supuestos
- Ticket Jira `ATDE-11`; rama `ATDE-11-mis-vinculos` (worktree aparte: el working tree de `main` tiene staged el borrado de ATDE-10, no se toca).
- Nombre `public.my_links()`; devuelve filas con `kind` (`membership` | `guardian`) en vez de JSON, para tipos generados precisos.
- `security definer` con filtro explícito por `auth.uid()`: un padre necesita el nombre de su transportista y la RLS de `operators` solo lo muestra a miembros.
- Empresa inactiva no se filtra, igual que `private.has_role` hoy; si se decide filtrar, se cambia ahí y aquí a la vez.
- Sin usuario lanza `28000` como `create_operator`; staff se devuelve como rol más (la vista de staff no existe aún).
