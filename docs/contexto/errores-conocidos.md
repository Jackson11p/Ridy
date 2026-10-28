# Errores conocidos y gotchas — [NOMBRE_PRODUCTO]

> Leyenda: **[IMPL]** problema real hoy en el repo · **[PLAN]** riesgo a cuidar al construir.

## Repo hoy [IMPL]

1. **`stash@{0}` sigue guardado**: su contenido ya está commiteado (RIDY-0001). Borrarlo es irreversible: hacer `git stash drop` solo tras confirmar que no falta nada.
2. **`.env.local` de cada dev** sigue con `NEXT_PUBLIC_*`: renombrar a mano a `EXPO_PUBLIC_*` (Expo solo expone ese prefijo). `.env.example` ya corregido.
3. **`@supabase/ssr` instalada sin uso**: sirve solo a frameworks con SSR. [PENDIENTE: quitarla o no según framework de la web pública]
4. **Agentes apuntan a cosas inexistentes**: `AGENTS.md` (solo `### TODO PATRICK`), `src/modules/`, `src/components/landing/`, `src/components/ui/` (shadcn), `pnpm validate`. Seguirlos al pie → errores.
5. **`npm install` falla a propósito** (`EBADENGINE`). Usar `corepack enable` + pnpm.
6. **Opción B (BD compartida)**: un `pnpm db:reset` del host borra los datos de todos. Credenciales locales son públicas (`postgres/postgres`): nunca a internet, nunca datos reales.
7. **Auth local sin OTP por teléfono**: `[auth.sms] enable_signup = false`, Twilio desactivado; `site_url` apunta a `127.0.0.1:3000`. No se puede probar login por teléfono aún.
8. **Diagramas embebidos perdidos**: mapa del sistema, turno de mañana (8 pasos) y fases salen como `[embedded content]` en el `.md`. [PENDIENTE: exportarlos]
9. Nombre provisional en identificadores: paquete `ridy`, `project_id = "Ridy"`, tickets `RIDY-`, código de ruta `RDY-`. Renombrar cuando haya marca.

## Seguridad y RLS [PLAN]

- RLS **desde la migración que crea la tabla**, nunca después. Sin RLS = datos de menores expuestos.
- Toda política filtra por `operator_id`; dueño/staff no ven otras empresas.
- Padre ve la buseta **solo con viaje activo**; nunca historial de ubicaciones fuera del viaje ni direcciones de otros.
- Canales Realtime `trip:<id>` **privados**: servidor valida que quien escucha sea encargado de un niño de ese viaje. Un canal público filtra ubicación de niños.
- `service_role` solo en Edge Functions. Nunca en app, `.env.example` ni repo.
- Escrituras sensibles por funciones SQL que validan rol, no inserts directos.
- Teléfono de encargados visible para el chofer (D4) → RLS lo limita a encargados de **sus viajes de hoy**.
- Código de ruta nunca da acceso sin aprobación. Agregar o quitar encargado también requiere aprobación (padres separados).

## Casos especiales del dominio [PLAN]

- **Nunca** mandar "llegó al colegio" a padres cuyo hijo no está "Abordó" en ese viaje.
- Reintentos del teléfono → push duplicado: usar `notifications_log` (idempotencia).
- "Hoy no va" después de "Iniciar ruta" → rechazar; mostrar "Avísale al chofer" con llamada.
- Niño con dos direcciones → parada distinta en AM y PM; no asumir una sola.
- Hermanos con mismo punto → agrupar, permitir "Abordaron todos".
- Sin señal > 2 min → mostrar "Última ubicación hace X min", nunca posición falsa. Eventos en cola local, envío al recuperar señal.
- Chofer olvida iniciar → recordatorio a hora habitual + 10 min, aviso al transportista.
- Chofer olvida finalizar → cierre automático (colegio en AM, última entrega en PM).
- Feriados → `calendar_days` evita crear viajes y avisos.
- Cambio de chofer/buseta solo en el viaje de hoy; no tocar la plantilla `routes`.
- Niño retirado → desactivar parada, no borrar historial.
- Fechas en UTC; mostrar en zona horaria de `operators`.
- `location_pings` particionada por mes; purga a 30 días obligatoria (Ley 8968).

## Privacidad (Ley 8968) [PLAN]

- Consentimiento explícito del encargado antes de ver o guardar datos del niño.
- Sin fotos, fechas de nacimiento, cédulas ni datos médicos.
- Encargado puede pedir borrado de sus datos y los del hijo desde la app. ⚠️ Choca con "nada se borra físicamente": [PENDIENTE: definir borrado real vs anonimización].
