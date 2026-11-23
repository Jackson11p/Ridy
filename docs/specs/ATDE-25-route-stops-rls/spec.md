# ATDE-25 — route_stops con RLS

## Problema
Un niño nunca se asigna directo a un chofer: se asigna a una parada dentro de una ruta. Sin paradas no hay pin de casa, orden de recorrido, vista "Hoy" del chofer ni aviso "cerca de casa". La dirección de un niño es dato sensible (Ley 8968).

## Requisitos
1. `route_stops`: ruta, estudiante, ubicación (punto), orden, radio de aviso (500 m por defecto), activa.
2. Un estudiante puede tener paradas distintas en AM y PM (rutas distintas, ubicaciones distintas).
3. Ruta y estudiante de la misma empresa; a lo sumo una parada activa por estudiante y ruta.
4. Desactivar en vez de borrar; cambiar de ruta o de estudiante = desactivar y crear otra (queda el historial).

## Criterios de aceptación
- `pnpm db:reset` sin errores; `pnpm test:db` en verde con pruebas pgTAP de la tabla.
- Dueño/staff ven, crean y editan paradas de su empresa; nunca de otra.
- Padre ve solo las paradas activas de sus hijos activos en rutas activas; nunca direcciones de otros niños.
- Chofer no ve paradas mientras no tenga viaje hoy (`trips` aún no existe); `anon` nada; nadie borra.

## Fuera de alcance
- Ordenar paradas (ATDE-26), pin de casa y consentimiento del padre (ATDE-30), `trips`/`attendance` (ATDE-31), geocerca y push, UI.

## Supuestos
- Ticket Jira `ATDE-25`; rama `ATDE-25-route-stops-rls`; tareas `ATDE-25-Tnn`.
- Chofer: "solo las de sus viajes de hoy" requiere `trips` (ATDE-31). Criterio conservador: sin política de chofer ahora (ni por buseta habitual); ATDE-31 la agrega vía viaje del día.
- Padre solo lectura; editar su pin llega con ATDE-30. Constitución §6: además exige ruta activa.
- Orden: entero > 0, sin unicidad por ruta (reordenar en ATDE-26 sin choques); empate se resuelve por id.
- Radio de aviso entre 100 y 2000 m. Sin texto de dirección ni notas: solo el punto (datos mínimos).
- No se valida "una parada activa por turno" entre rutas distintas; si hace falta, ticket propio.
