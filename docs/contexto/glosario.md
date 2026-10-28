# Glosario — [NOMBRE_PRODUCTO]

> Todo el dominio es **[PLAN]** (solo en `docs/arquitectura-sistema.md`): no hay tablas ni código aún.
> Términos de entorno marcados **[IMPL]**.

## Actores

| Término | Código | Significado |
|---|---|---|
| Transportista / dueño | `owner` | Dueño de la empresa de transporte. Crea busetas, rutas, estudiantes; invita choferes y padres. Nos paga mensual |
| Chofer | `driver` | Maneja; inicia ruta, marca "Abordó"/"No salió"/"Entregado". Puede ser el mismo dueño |
| Staff | `staff` | Personal de oficina del transportista |
| Padre / encargado | `guardians` | Persona vinculada a un estudiante. Ve buseta en vivo, recibe avisos, marca "Hoy no va" |
| Admin [NOMBRE_PRODUCTO] | — | Nosotros: soporte, alta en beta, facturación. Cada acceso queda registrado |

## Entidades (tablas planeadas)

| Término | Tabla | Qué es |
|---|---|---|
| Persona | `profiles` | 1 a 1 con `auth.users`: nombre, teléfono, token push, idioma |
| Empresa | `operators` | Transportista: país, moneda, zona horaria, plan |
| Membresía | `memberships` | Rol de una persona en una empresa (puede tener varios) |
| Buseta | `vehicles` | Placa, capacidad, chofer habitual |
| Colegio | `schools` | Nombre, ubicación, radio de geocerca |
| Ruta | `routes` | **Plantilla fija**: colegio + turno (AM/PM) + buseta + código de ruta |
| Estudiante | `students` | Niño: nombre, colegio, activo (sin foto, ver D7) |
| Parada | `route_stops` | Niño dentro de una ruta: ubicación, orden, radio de aviso. Una en AM y otra en PM |
| Viaje | `trips` | Ruta de **un día concreto**: chofer, buseta y horas reales |
| Asistencia | `attendance` | Estado del niño en un viaje |
| Bitácora | `trip_events` | Inicio, geocercas, fin, cambios |
| Invitación | `invitations` | Teléfono pendiente de vincular, con vencimiento |
| Solicitud | `join_requests` | Pedido por código de ruta, espera aprobación |
| Calendario | `calendar_days` | Días sin clases (no se crean viajes) |
| Ping | `location_pings` | Muestra de ubicación; purga a 30 días |
| Log de avisos | `notifications_log` | Evita push duplicados |
| Suscripción | `subscriptions` | Cobro mensual a la empresa |

Cadena clave: **Estudiante → Parada → Ruta → Buseta → Chofer del día**.

## Estados de asistencia

`esperado` · `ausente avisado` · `abordó` · `no salió` · `entregado`. [PENDIENTE: valores exactos en inglés para el enum]

## Términos de operación

- **Turno**: mañana (AM: casa → colegio) o tarde (PM: colegio → casa).
- **Hoy no va**: aviso del padre de que el niño no viaja; quita la parada. Vale hasta "Iniciar ruta". Admite rango de días.
- **Geocerca**: radio alrededor de parada (500 m → "cerca de casa") o colegio ("llegó al colegio").
- **Código de ruta**: código corto tipo `RDY-4K7P` para pedir vínculo. [PENDIENTE: prefijo depende del nombre final]
- **Chofer del día**: chofer habitual de la buseta, o sustituto puesto solo en el viaje de hoy.
- **Camino A / B**: alta de padre por pre-registro de teléfono (A, principal) o por código de ruta (B, respaldo).
- **Modo conducción**: vista del chofer con botón único iniciar/finalizar.
- **B2B2C**: transportista cobra a padres con nuestra tarifa incluida; nos paga a nosotros.

## Siglas

| Sigla | Significado |
|---|---|
| OTP | Código de un solo uso para login (WhatsApp, SMS respaldo) |
| RLS | Row Level Security de Postgres |
| RPC | Llamada a función SQL desde el cliente |
| ADR | Registro corto de decisión de arquitectura en `docs/` |
| MVP / beta | Primera versión, 1–2 busetas |
| `RIDY-NNNN` | Ticket interno [IMPL]; `RIDY-NNNN-Tnn` = tarea |
| Ley 8968 | Ley de protección de datos personales de Costa Rica |
| Stack local | Contenedores Supabase en Docker Desktop [IMPL] |
| Seed | `supabase/seed.sql`, datos de desarrollo [IMPL, vacío] |
