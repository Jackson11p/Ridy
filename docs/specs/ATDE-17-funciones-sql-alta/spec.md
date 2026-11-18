# ATDE-17 — Funciones SQL de alta: crear empresa con dueño e invitar chofer

## Problema
El alta del transportista (pasos 1 y 3 de `docs/arquitectura-sistema.md`) hace escrituras sensibles: crear la empresa con su dueño, invitar choferes y que el dueño se marque como chofer. Deben validar sesión y rol en la BD, no confiar en inserts directos del cliente.

## Requisitos
1. Crear empresa genera `operator` + `membership owner` en una sola transacción (ya existe `create_operator`, ATDE-8).
2. Invitar chofer crea una `invitation` de rol `driver` en una empresa; solo owner/staff activos de esa empresa.
3. El dueño puede marcarse como chofer de su empresa: queda con dos roles (owner + driver).
4. Inserts directos de cliente a `operators`, `memberships` e invitaciones de rol siguen rechazados.

## Criterios de aceptación
- `pnpm db:reset` sin errores y `pnpm test:db` en verde.
- pgTAP: owner y staff invitan chofer; driver, anon, sin sesión y otra empresa rechazados; quien invita = sesión.
- pgTAP: owner se marca chofer y conserva owner; staff, driver y otra empresa rechazados; repetirlo no duplica.
- pgTAP: si `create_operator` falla al crear la membership, no queda empresa huérfana.

## Fuera de alcance
- UI, hooks y contratos móviles (historias ATDE-18 "Crear mi empresa" y ATDE-20 "Invitar choferes").
- Aceptar la invitación (`accept-invite`, ATDE-27) y envío del mensaje (ATDE-28). Invitar staff.

## Supuestos
- Ticket Jira `ATDE-17`; rama `ATDE-17-funciones-sql-alta`; tareas `ATDE-17-Tnn`.
- Solo BD: ninguna pantalla consume aún las RPC; los tipos de `packages/shared` se regeneran.
- Sin columna de nombre en la invitación: el chofer pone su nombre en su perfil al aceptar (YAGNI; ATDE-20 lo pide si hace falta).
- Teléfono en dígitos (8–15), como `profiles.phone`; lo valida el check existente.
- Invitación pendiente vigente al mismo teléfono → error de duplicado. Una pendiente **vencida** se desactiva y se crea otra (si no, nadie podría reinvitar: el cliente no edita invitaciones de rol).
- Marcarse chofer: solo el owner (no staff); si ya tuvo rol driver inactivo, se reactiva.
