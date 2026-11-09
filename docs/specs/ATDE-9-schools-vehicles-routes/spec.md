# ATDE-9 — schools, vehicles y routes (PostGIS) con RLS

## Problema
Para operar un día de transporte hace falta la plantilla fija de cada empresa: la buseta, el colegio (con su punto y geocerca para "llegó al colegio") y la ruta que une colegio + turno + buseta. Sin estas tablas no hay paradas, viajes ni avisos.

## Requisitos
1. PostGIS activado por migración.
2. `vehicles`: placa, capacidad, chofer habitual (opcional), activa.
3. `schools`: nombre, ubicación (punto geográfico), radio de geocerca en metros.
4. `routes`: colegio, turno (mañana/tarde), buseta habitual, código de ruta corto y único, activa.
5. Todas con `operator_id`, llave UUID, fechas UTC y desactivación en vez de borrado.
6. Una ruta solo une colegio y buseta de su misma empresa; el chofer habitual es chofer activo de esa empresa.

## Criterios de aceptación
- `pnpm db:reset` aplica sin errores; `pnpm test:db` en verde con pruebas pgTAP por tabla.
- Dueño/staff ven, crean y editan lo de su empresa; nunca lo de otra.
- Chofer solo lee la buseta que maneja, las rutas de esa buseta y sus colegios; no escribe.
- `anon` no ve nada; nadie borra filas; nadie mueve una fila a otra empresa ni edita el código de ruta.

## Fuera de alcance
- `route_stops`, `trips`, join por código (Camino B), UI, funciones SQL de alta (ATDE-17).

## Supuestos
- Ticket Jira `ATDE-9`; rama `ATDE-9-schools-vehicles-routes`; tareas `ATDE-9-Tnn`.
- "Lo de sus viajes" del chofer = hoy, rutas cuya buseta lo tiene como chofer habitual (aún no existe `trips`); al llegar `trips` se amplía al chofer del viaje de hoy. Chofer solo ve filas activas.
- Alta y edición directas con RLS para dueño/staff (no son escrituras sensibles de la arquitectura).
- Código de ruta lo genera la BD (`RDY-` + 6 caracteres sin ambiguos), único global (lo usarán padres en Camino B); prefijo provisional (errores-conocidos #9).
- Placa única por empresa; capacidad 1–60; radio de geocerca por defecto 200 m, rango 50–2000 m.
- Turno como enum `am`/`pm`.
