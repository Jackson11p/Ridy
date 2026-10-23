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

**Panel admin**
- Alta de choferes, rutas y estudiantes.

## Modelo de negocio

- Padres: ~$4.50–5 USD/mes por estudiante (~₡2,500–3,000 CRC).
- Chofer: gratis → es quien promueve Ridy entre los padres de su ruta.

## Stack

| Capa | Herramienta |
|---|---|
| App móvil (padres + chofer) | Expo (React Native) + TypeScript, una app con dos roles, Expo Router |
| Datos y estado | TanStack Query + cliente Supabase |
| GPS en segundo plano | `expo-location` + `expo-task-manager` (beta) |
| Mapas | `react-native-maps` |
| Backend | Supabase: Postgres + PostGIS, Auth (OTP SMS), Realtime, Edge Functions, pg_cron |
| Push | Expo Notifications (FCM/APNs) desde Edge Function |
| Rutas | Orden manual en beta; OSRM en VPS después |
| Panel admin | React + Vite |
| Errores | Sentry |
| CI | GitHub Actions: tsc + lint + pruebas RLS |

## Estado

Pre-desarrollo. Meta: beta con 1–2 busetas.

## Cómo se trabaja

- Reglas del proyecto: [`docs/constitution.md`](docs/constitution.md).
- Flujo spec → plan → tareas: [`Claude.md`](Claude.md). Specs en `docs/specs/TICKET-nombre/`.
