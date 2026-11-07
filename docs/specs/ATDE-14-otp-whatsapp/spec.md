# ATDE-14 — Auth OTP por WhatsApp

## Problema

Login de choferes y padres es teléfono + OTP por WhatsApp (D8), pero hoy `[auth.sms]` está apagado y no hay proveedor: nadie puede entrar ni probar login (ATDE-15 bloqueado). Equipo no quiere pagar nada hasta tener clientes.

## Objetivo

OTP por WhatsApp funcionando a $0 en desarrollo, con el mismo camino que irá a producción (Meta WhatsApp Cloud API directo).

## Criterios de aceptación

1. Proveedor elegido y anotado en D8 (`docs/contexto/decisiones.md`): Meta Cloud API directo; SMS de respaldo pospuesto a beta.
2. Números de prueba con código fijo permiten login local sin enviar nada.
3. Para cualquier otro número, Supabase Auth delega el envío en un hook que manda el código por WhatsApp (plantilla de autenticación de Meta).
4. Sin credenciales Meta cargadas, el hook responde error claro y no envía nada.
5. Solo Supabase Auth puede ejecutar el hook; `anon` y `authenticated` no.
6. Secretos Meta solo en Vault local / env, nunca en el repo.
7. Rate limit de envíos y espera mínima entre reenvíos configurados.
8. README explica cómo cargar credenciales y probar contra un número real (número de prueba de Meta, máx. 5 destinatarios).

## Fuera de alcance

- Respaldo por SMS y número de producción de Meta (ticket de beta, pendiente de crear).
- Pantallas de login (ATDE-15). Supabase remoto.

## Supuestos

- Ticket Jira `ATDE-14`; rama y carpeta `ATDE-14-otp-whatsapp`; tareas `ATDE-14-Tnn`.
- Hook como función Postgres + `pg_net` (extensión de Supabase) y pruebas pgTAP: elegido por el usuario; sin deps nuevas.
- Prueba con número real es manual (requiere app de Meta del dev); no la cubre CI.
- Criterio "respaldo SMS" del ticket se mueve fuera de alcance por costo.
