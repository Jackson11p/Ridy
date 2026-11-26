# ATDE-39 — Registrar el token push del teléfono en profiles

## Problema
Los avisos "inició ruta" / "cerca de casa" / "llegó al colegio" (MVP) salen por Expo Notifications desde una Edge Function (`notify`). Sin el token de cada teléfono guardado en su `profile` no hay a quién mandarlos.

## Requisitos
1. Tras el login la app pide permiso de notificaciones, obtiene el token Expo y lo guarda en el `profile` de quien inició sesión.
2. Si el token cambia (reinstalación, rotación) se guarda el nuevo; al abrir la app con sesión se vuelve a registrar.
3. Permiso denegado o dispositivo sin push: la app sigue funcionando y muestra un aviso discreto de que no recibirá avisos.
4. Al cerrar sesión se borra el token del perfil antes de cerrar la sesión.
5. Un teléfono = un dueño del token: si otra persona inicia sesión en el mismo teléfono, el token deja de estar en el perfil anterior (no le llegan avisos de niños ajenos).

## Criterios de aceptación
- Cada persona solo escribe su propio token; nadie (ni ella misma) lo lee desde la app; `anon` nada. Pruebas pgTAP.
- Token con formato Expo válido; perfil inactivo no registra token.
- Android (canal de notificaciones) e iOS usan el mismo flujo; tests de dominio, aplicación, infraestructura y hook en verde.
- `pnpm db:reset`, `pnpm test:db`, typecheck, lint y `pnpm test` en verde.

## Fuera de alcance
- Edge Function `notify`, `notifications_log`, envío de avisos, botón de cerrar sesión en pantalla (no existe aún), configuración EAS/FCM/APNs.

## Supuestos
- Ticket Jira `ATDE-39`; rama `ATDE-39-token-push` (worktree aparte).
- Dep `expo-notifications` aprobada por el usuario (2026-11-23), versión fijada por SDK 58; sin `expo-device`.
- `projectId` EAS y credenciales FCM/APNs viven fuera del repo; sin ellos, en emulador o en web el registro queda "no disponible" sin romper la app.
- Escritura del token solo por función SQL (se revoca el update directo de `push_token`) para garantizar el punto 5.
- Cerrar sesión: caso de uso y hook listos; el botón llega con su pantalla. Si borrar el token falla, igual se cierra sesión.
- El aviso de permiso denegado se muestra en el layout raíz mientras haya sesión.
