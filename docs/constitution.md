# Constitución de Ridy
Reglas no negociables. Todo agente (`planner`, `coder`, `reviwer`) y persona las lee antes de planear o tocar código; si una spec choca con este doc, gana este doc. Cambiarlo requiere acuerdo del usuario. Agentes no son obligatorios: solo para tareas largas, complejas o complicadas (detalle en `Claude.md`); resto se trabaja directo. `[POR DEFINIR]` = decide el usuario; nadie lo rellena suponiendo.
## 1. Problema
- **Problema:** padres no saben dónde está la buseta escolar ni cuándo llega; choferes pierden tiempo, combustible y atención contestando llamadas/WhatsApp mientras manejan.
- **Usuarios:** transportista (dueño: administra todo desde la app y nos hace un solo pago mensual), choferes y padres. Cobro B2B2C: los padres le pagan al transportista con nuestra tarifa incluida; sin pagos dentro de la app.
- **MVP (beta, 1–2 busetas):** buseta en vivo en mapa; push "inició ruta" / "cerca de casa (500 m)" / "llegó al colegio"; botón "Hoy no va" que quita la parada; chofer con botón único iniciar/finalizar y lista de paradas ordenada; perfil de varios hijos y estado de suscripción.
- **NO hace (beta):** optimización automática de rutas (orden manual; OSRM después). Resto fuera de alcance [POR DEFINIR]. Toda feature nueva se justifica contra este problema; si no encaja → fase posterior (`/scope`).
## 2. Stack
- Expo (React Native) + TypeScript, una app con todos los roles (padre, chofer, dueño); Expo Router; TanStack Query + cliente Supabase; GPS beta `expo-location` + `expo-task-manager`; `react-native-maps`; Expo Notifications enviadas desde Edge Function; administración dentro de la app (sin panel web); web pública solo landing + directorio de transportistas que aceptan aparecer (framework [POR DEFINIR]); Sentry; CI GitHub Actions (tsc + lint + pruebas RLS).
- Mínimas deps. Nueva dep, cambio de stack o API de pago por llamada (Google Directions/Matrix) = decisión del usuario, anotada aquí.
- Decisiones tomadas: gestor **pnpm únicamente** (npm bloqueado vía `engines` + `.npmrc`); dev con Supabase local en Docker Desktop y CLI `supabase` como devDependency. RIDY-0001.
## 3. Spec y código
- Sin spec no hay código (flujo y longitudes en `Claude.md`). Cada tarea = test + cambio mínimo = un commit. Si algo no encaja → se actualiza la spec primero; con agentes, `reviwer` verifica cada commit contra su spec.
## 4. Capas
- Arquitectura [POR DEFINIR]. Mínimo fijo: cero lógica de negocio en componentes UI; I/O (Supabase, GPS, push) aislado tras contratos; archivos < 150 líneas, funciones < 30.
## 5. Pruebas (TDD)
- Rojo → verde → refactor. Sin test no hay commit; bug fix empieza con test que lo reproduce. Toda tabla con políticas RLS tiene prueba RLS. Runner de tests [POR DEFINIR].
## 6. Datos
- Supabase: Postgres + PostGIS, Auth (OTP por WhatsApp, SMS de respaldo), Realtime, Edge Functions, RLS, pg_cron. Esquema solo por migraciones versionadas; RLS en toda tabla; validar en cada límite; secretos en env, nunca en repo. Ubicación de menores = dato sensible: solo la ven padres de esa ruta y solo con ruta activa. Sin fotos de niños. El chofer sí ve el teléfono de los encargados de sus viajes.
