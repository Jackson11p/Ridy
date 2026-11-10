# ATDE-10 — students, guardians e invitations con RLS

## Problema
Para cargar niños, invitar padres y que el padre vea a su hijo al entrar (Camino A) hacen falta: el estudiante, el vínculo encargado ↔ estudiante y la invitación pendiente por teléfono. Datos de menores: mínimos y nunca visibles fuera de quien corresponde (Ley 8968).

## Requisitos
1. `students`: nombre, colegio, activo. Sin foto, fecha de nacimiento, cédula ni datos médicos.
2. `guardians`: persona ↔ estudiante, relación, si recibe avisos. Un niño varios encargados; un padre varios hijos.
3. `invitations`: teléfono, rol o estudiante (uno de los dos), quién invitó, vencimiento, aceptada.
4. Todas con `operator_id`, UUID, UTC, desactivación en vez de borrado; nada mezcla empresas.

## Criterios de aceptación
- `pnpm db:reset` sin errores; `pnpm test:db` en verde con pruebas pgTAP por tabla.
- Dueño/staff ven y gestionan estudiantes e invitaciones de su empresa, y ven sus encargados.
- Padre ve solo a sus hijos activos y su propio vínculo; nunca otros niños ni otros encargados.
- Nadie ve niños, vínculos ni invitaciones de otra empresa; `anon` nada; nadie borra.

## Fuera de alcance
- Aceptar invitación / crear vínculo (`accept-invite`, ATDE-27), invitar chofer/staff (ATDE-17), consentimiento (ATDE-30), envío de invitaciones (ATDE-28), paradas (ATDE-25), UI.

## Supuestos
- Ticket Jira `ATDE-10`; rama `ATDE-10-students-guardians-invitations`; tareas `ATDE-10-Tnn`.
- `guardians` sin insert desde clientes: lo crea `accept-invite` o la aprobación (tickets propios). Owner/staff solo desactivan; padre solo cambia "recibe avisos".
- Invitaciones directas desde cliente solo de estudiante (owner/staff); las de rol las crea la función de ATDE-17 (evita que staff invite a un owner). `invited_by` lo pone la BD; vence a 14 días.
- El invitado no lee su invitación por RLS; la resuelve `accept-invite` del lado servidor.
- Chofer no ve estudiantes hasta `route_stops`/`trips`; padre aún no ve colegio ni buseta (ATDE-29).
- Relación como enum (`mother`, `father`, `grandparent`, `legal_guardian`, `other`); teléfono solo dígitos, 8–15, como `profiles.phone`.
- Owner/staff ven perfil (nombre, teléfono) de encargados activos de sus estudiantes.
