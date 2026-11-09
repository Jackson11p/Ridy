# Errores conocidos y gotchas — [NOMBRE_PRODUCTO]

> Leyenda: **[IMPL]** problema real hoy en el repo · **[PLAN]** riesgo a cuidar al construir.

## Repo hoy [IMPL]

1. **`stash@{0}` sigue guardado**: su contenido ya está commiteado (RIDY-0001). Borrarlo es irreversible: hacer `git stash drop` solo tras confirmar que no falta nada.
2. **`.env.local` de cada dev** sigue con `NEXT_PUBLIC_*`: renombrar a mano a `EXPO_PUBLIC_*` (Expo solo expone ese prefijo). `.env.example` ya corregido.
3. **`@supabase/ssr` instalada sin uso**: sirve solo a frameworks con SSR. [PENDIENTE: quitarla o no según framework de la web pública]
4. **`pnpm exec supabase test db` sin tests aún**: `pnpm typecheck|lint|test` ya existen (ATDE-6); pgTAP llega con la primera migración. `AGENTS.md` sigue con solo `### TODO PATRICK` (ya nadie lo cita).
5. **`npm install` falla a propósito** (`EBADENGINE`). Usar `corepack enable` + pnpm.
6. **Opción B (BD compartida)**: un `pnpm db:reset` del host borra los datos de todos. Credenciales locales son públicas (`postgres/postgres`): nunca a internet, nunca datos reales.
7. **OTP por WhatsApp solo local (ATDE-14)**: números `test_otp` de `config.toml` entran con código fijo sin enviar nada; el resto pasa por el hook `public.send_sms_hook` → Meta. Secretos Meta viven en Vault local y **se pierden con `db reset`** (recargar, ver README). `pg_net` es asíncrono: Auth no sabe si Meta entregó (revisar `net._http_response`). Número de prueba de Meta: máx. 5 destinatarios registrados. `site_url` apunta a `127.0.0.1:3000`. Este `config.toml` (Twilio con valores de relleno + hook `pg-functions://`) es solo local: **no se empuja tal cual al remoto**; revisarlo en el ticket de beta. **Bloqueo Meta (2026-11-07):** crear la plantilla de autenticación falla con `This WhatsApp business account does not have permission to create message template`; Meta exige verificación del negocio para plantillas de autenticación. [PENDIENTE: verificar negocio en Business Manager (requiere datos legales de la empresa)]. Hasta entonces, dev solo con `test_otp`; `hello_world` sirve para probar token y número.
8. **Diagramas embebidos perdidos**: mapa del sistema, turno de mañana (8 pasos) y fases salen como `[embedded content]` en el `.md`. [PENDIENTE: exportarlos]
9. Nombre provisional en identificadores: paquete `ridy`, `project_id = "Ridy"`, tickets `RIDY-`, código de ruta `RDY-`. Renombrar cuando haya marca.
10. **pnpm 11 y paquetes recién publicados**: `pnpm add pkg@<versión de hoy>` agrega solo `minimumReleaseAgeExclude` a `pnpm-workspace.yaml`. No commitearlo: pedir rango (`pkg@^N`) y dejar que elija una versión con antigüedad.
11. **Build scripts bloqueados (pnpm 11)**: dep nueva con script → `ERR_PNPM_IGNORED_BUILDS`; decidir en `allowBuilds` de `pnpm-workspace.yaml` (true/false), con comentario del porqué.
12. **Aviso de peer `react-dom` 19.3.1 vs `react` 19.3.0**: lo trae expo-router por web; sin web en la app no afecta. Revisar al subir de SDK.

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
