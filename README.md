# Ridy

Transporte escolar seguro y sin llamadas. Padres ven la buseta en vivo y reciben avisos automáticos; choferes manejan sin contestar WhatsApp.

## Problema

- **Padres:** no saben dónde está la buseta, cuándo llega ni si su hijo llegó al colegio.
- **Choferes:** pierden tiempo, combustible y atención respondiendo llamadas y mensajes mientras manejan.

## Qué hace

**App padres**
- Buseta en tiempo real en el mapa durante la ruta.
- Push automáticos: "inició la ruta", "está cerca de tu casa (500 m)", "tu hijo llegó al colegio".
- Botón **"Hoy no va"**: avisa con un toque que el estudiante no viaja.
- Perfil de varios hijos y estado de suscripción.

**App chofer**
- Botón único para iniciar/finalizar ruta (modo conducción).
- Lista de paradas ordenada; si un padre marca "Hoy no va", la parada sale de la ruta.

**Administración (dentro de la app, rol dueño)**
- Alta de choferes, busetas, rutas y estudiantes.

**Web pública**
- Landing y directorio de transportistas que aceptan aparecer. Sin administración.

## Modelo de negocio

- B2B2C: los padres le pagan al transportista con nuestra tarifa incluida. Monto por confirmar (referencia previa: ~$4.50–5 USD/mes por estudiante, ~₡2,500–3,000 CRC).
- El transportista nos hace un solo pago mensual. Sin pagos dentro de la app.

## Stack

| Capa | Herramienta |
|---|---|
| App móvil (padres, chofer, dueño) | Expo (React Native) + TypeScript, una app con todos los roles, Expo Router |
| Datos y estado | TanStack Query + cliente Supabase |
| GPS en segundo plano | `expo-location` + `expo-task-manager` (beta) |
| Mapas | `react-native-maps` |
| Backend | Supabase: Postgres + PostGIS, Auth (OTP WhatsApp, SMS de respaldo), Realtime, Edge Functions, pg_cron |
| Push | Expo Notifications (FCM/APNs) desde Edge Function |
| Rutas | Orden manual en beta; OSRM en VPS después |
| Web pública | Landing + directorio (framework por definir) |
| Errores | Sentry |
| CI | GitHub Actions: tsc + lint + pruebas RLS |

## Estado

Pre-desarrollo. Meta: beta con 1–2 busetas.

## Cómo se trabaja

- Reglas del proyecto: [`docs/constitution.md`](docs/constitution.md).
- Flujo spec → plan → tareas: [`Claude.md`](Claude.md). Specs en `docs/specs/TICKET-nombre/`.

## Entorno de desarrollo

El proyecto usa **solo pnpm**: `npm install` falla a propósito (`EBADENGINE`). La BD es Supabase local corriendo en Docker Desktop.

### Requisitos

- Node.js >= 22
- Docker Desktop con backend WSL2, abierto y en "Engine running"
- pnpm vía corepack (fija la versión declarada en `package.json`):

```powershell
corepack enable
```

### Primer arranque

```powershell
pnpm install
pnpm db:start                     # primera vez descarga imágenes (tarda)
pnpm db:reset                     # aplica migraciones + supabase/seed.sql
Copy-Item apps/mobile/.env.example apps/mobile/.env.local # pegar la Publishable key de `pnpm db:status`
```

| Servicio | URL |
|---|---|
| API | http://127.0.0.1:54321 |
| Postgres | `postgresql://postgres:postgres@127.0.0.1:54322/postgres` |
| Studio | http://127.0.0.1:54323 |
| Mailpit (emails de auth) | http://127.0.0.1:54324 |

### Scripts

| Script | Qué hace |
|---|---|
| `pnpm db:start` | Levanta el stack |
| `pnpm db:stop` | Lo apaga (conserva datos) |
| `pnpm db:status` | URLs y keys |
| `pnpm db:reset` | Borra la BD local y reaplica migraciones + seed |
| `pnpm db:migration <nombre>` | Crea `supabase/migrations/<timestamp>_<nombre>.sql` |
| `pnpm db:diff <nombre>` | Genera una migración desde cambios hechos en Studio |
| `pnpm db:types` | Regenera `packages/shared/src/database.types.ts` (correr tras cada migración) |

El schema cambia **solo por migraciones** commiteadas. Tras un `git pull` con migraciones nuevas: `pnpm db:reset`.

### Tests

TDD: primero el test, verlo fallar (rojo), luego el código (verde). Runners en [ADR-0001](docs/adr/0001-capas-y-runner.md).

| Suite | Comando | Archivos | Necesita |
|---|---|---|---|
| JS/TS (`jest-expo`) | `pnpm test` | `apps/mobile/**/*.test.ts(x)` | nada |
| SQL/RLS (pgTAP) | `pnpm test:db` | `supabase/tests/*.test.sql` | `pnpm db:start` |

- Toda tabla con políticas RLS lleva su prueba. Patrón a copiar: [`supabase/tests/rls-ejemplo.test.sql`](supabase/tests/rls-ejemplo.test.sql) (simula `anon` y usuarios `authenticated` con `set local role` + `request.jwt.claims`; todo dentro de `begin … rollback`).
- Si `pnpm db:start` falla por puerto ocupado (`54322`), otro proyecto Supabase está arriba: `supabase stop --project-id <otro>`.

### Login por teléfono (OTP por WhatsApp)

Auth delega el envío del código en el hook `public.send_sms_hook`, que lo manda por la API de WhatsApp Cloud de Meta (D8, ATDE-14). Espera mínima entre reenvíos: 60 s; tope: 30 envíos/hora.

**Sin nada que configurar ($0):** los números de `[auth.sms.test_otp]` en `supabase/config.toml` (`50670000001`, `50670000002`, `50670000003`) entran con el código `123456` y no envían nada.

**Contra un número real (número de prueba de Meta, gratis):**

1. En [developers.facebook.com](https://developers.facebook.com) crea una app de tipo Business y agrega el producto WhatsApp. Meta te da un número de prueba y su **Phone number ID**.
2. En *API Setup* registra los destinatarios (máx. 5) y genera un token de acceso (el temporal dura 24 h; para uno fijo, usuario del sistema en Business Manager).
3. En *WhatsApp Manager → Plantillas* crea una plantilla categoría **Autenticación**, idioma **Español (es)**, con botón "Copiar código". Anota su nombre.
   - Si Meta responde `Cannot Create Message Template — This WhatsApp business account does not have permission to create message template`: Meta exige **verificación del negocio** (Business Manager → Centro de seguridad) para plantillas de autenticación. Sin empresa verificada no hay OTP real; seguir con `test_otp` (ver errores conocidos, punto 7).
   - Mientras tanto, para comprobar token, Phone number ID y destinatario a $0, envía la plantilla preaprobada `hello_world` (no lleva código, solo prueba la conexión):

     ```powershell
     $h = @{ Authorization = "Bearer <token>" }
     Invoke-RestMethod -Method Post -Uri https://graph.facebook.com/v23.0/<phone number id>/messages -Headers $h -ContentType "application/json" -Body '{"messaging_product":"whatsapp","to":"5068XXXXXXX","type":"template","template":{"name":"hello_world","language":{"code":"en_US"}}}'
     ```
4. Carga los tres secretos en el Vault local (Studio → SQL Editor, http://127.0.0.1:54323). Nunca los pongas en archivos del repo:

   ```sql
   select vault.create_secret('<token>', 'meta_wa_token');
   select vault.create_secret('<phone number id>', 'meta_wa_phone_number_id');
   select vault.create_secret('<nombre de la plantilla>', 'meta_wa_template');
   -- cambiar uno: select vault.update_secret((select id from vault.secrets where name = 'meta_wa_token'), '<nuevo>');
   ```

5. Prueba con tu número registrado (código de país sin `+`, p. ej. `5068XXXXXXX`), con la Publishable key de `pnpm db:status`:

   ```powershell
   $h = @{ apikey = "<publishable key>" }
   Invoke-RestMethod -Method Post -Uri http://127.0.0.1:54321/auth/v1/otp -Headers $h -ContentType "application/json" -Body '{"phone":"5068XXXXXXX"}'
   Invoke-RestMethod -Method Post -Uri http://127.0.0.1:54321/auth/v1/verify -Headers $h -ContentType "application/json" -Body '{"phone":"5068XXXXXXX","token":"<código>","type":"sms"}'
   ```

- Sin los tres secretos, `/otp` responde 500 "Meta WhatsApp no configurado" y no envía nada.
- El envío es asíncrono (`pg_net`): Auth responde `{}` aunque Meta rechace. Si no llega el WhatsApp: `select status_code, content from net._http_response order by id desc limit 5;`
- Los secretos del Vault **se pierden con `pnpm db:reset`**: vuelve a cargarlos.
- Twilio aparece `enabled = true` con valores de relleno solo porque el CLI apaga el login por teléfono sin proveedor; con el hook activo nunca se usa.

### Conexión del equipo

**Opción A (recomendada): cada dev su propia BD.** Cada uno corre los pasos de "Primer arranque". El schema y el seed vienen de git, así que todos quedan iguales y nadie pisa los datos de otro.

**Opción B: todos contra la BD de un dev (host).**

1. El host saca su IP con `ipconfig` (IPv4), p. ej. `192.168.1.50`.
2. El host abre el firewall (PowerShell como admin, solo en redes privadas):

   ```powershell
   New-NetFirewallRule -DisplayName "Supabase local" -Direction Inbound -Protocol TCP -LocalPort 54321-54324 -Action Allow -Profile Private
   ```

3. El resto pone en `apps/mobile/.env.local` `EXPO_PUBLIC_SUPABASE_URL=http://192.168.1.50:54321` y la Publishable key del host.
4. Fuera de la misma red: usar Tailscale y la IP de Tailscale del host. Nunca abrir puertos en el router.

Con la opción B, el PC del host tiene que estar encendido con Docker corriendo, y un `pnpm db:reset` del host borra los datos de todos.

> **Seguridad:** el stack local usa credenciales por defecto conocidas públicamente (`postgres/postgres`, keys de demo). Solo se expone en una red de confianza o por Tailscale, nunca a internet, y nunca se guardan datos reales.
