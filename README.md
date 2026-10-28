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
Copy-Item .env.example .env.local # y pegar la Publishable key de `pnpm db:status`
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

El schema cambia **solo por migraciones** commiteadas. Tras un `git pull` con migraciones nuevas: `pnpm db:reset`.

### Conexión del equipo

**Opción A (recomendada): cada dev su propia BD.** Cada uno corre los pasos de "Primer arranque". El schema y el seed vienen de git, así que todos quedan iguales y nadie pisa los datos de otro.

**Opción B: todos contra la BD de un dev (host).**

1. El host saca su IP con `ipconfig` (IPv4), p. ej. `192.168.1.50`.
2. El host abre el firewall (PowerShell como admin, solo en redes privadas):

   ```powershell
   New-NetFirewallRule -DisplayName "Supabase local" -Direction Inbound -Protocol TCP -LocalPort 54321-54324 -Action Allow -Profile Private
   ```

3. El resto pone en `.env.local` `EXPO_PUBLIC_SUPABASE_URL=http://192.168.1.50:54321` y la Publishable key del host.
4. Fuera de la misma red: usar Tailscale y la IP de Tailscale del host. Nunca abrir puertos en el router.

Con la opción B, el PC del host tiene que estar encendido con Docker corriendo, y un `pnpm db:reset` del host borra los datos de todos.

> **Seguridad:** el stack local usa credenciales por defecto conocidas públicamente (`postgres/postgres`, keys de demo). Solo se expone en una red de confianza o por Tailscale, nunca a internet, y nunca se guardan datos reales.
