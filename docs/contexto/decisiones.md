# Decisiones técnicas — [NOMBRE_PRODUCTO]

> Leyenda: **[IMPL]** reflejada en el repo · **[PLAN]** decidida, sin código aún · **[ABIERTA]** sin cerrar.
> D3–D9 ya reflejadas en `docs/arquitectura-sistema.md`, README y constitución (RIDY-0002).

## Confirmadas por los socios

| # | Decisión | Por qué | Descartado | Estado |
|---|---|---|---|---|
| D1 | Móvil: **Expo + React Native + TypeScript** | Un solo lenguaje, comparte código con la web | Flutter (otro lenguaje, no comparte con web); nativo (dos códigos) | [PLAN] |
| D2 | Backend: **Supabase** (Postgres + PostGIS, Auth, Realtime, Edge Functions, RLS) | Todo en uno; seguridad en BD | [PENDIENTE: alternativas evaluadas] | [IMPL] solo local (CLI + `config.toml`) |
| D3 | Cobro **B2B2C**: padres pagan al transportista con nuestra tarifa incluida; transportista nos paga **un solo pago mensual**. Sin pagos en app | Evita pagos in-app y comisión de tiendas | Cobro directo a cada padre | [PLAN] |
| D4 | Chofer **ve el teléfono** de los encargados | Decisión de socios | Solo botón "Llamar" sin número | [PLAN] |
| D5 | **"Hoy no va"** vale hasta que el chofer inicia la ruta | Después la parada ya está en curso | Hora fija | [PLAN] |
| D6 | **Cambio de dirección**: lo propone el padre, lo aprueba el transportista | Control sobre el recorrido | Padre edita su pin libremente | [PLAN] |
| D7 | **Sin fotos de niños** | Un dato sensible menos (Ley 8968) | Foto opcional | [PLAN] |
| D8 | **OTP por WhatsApp**, SMS de respaldo | WhatsApp suele salir más barato en la región | Solo SMS | [PLAN] — proveedor [PENDIENTE] |
| D9 | **Administración toda en la app**; web solo pública (landing + directorio de transportistas que aceptan aparecer) | Un solo lugar de gestión | Panel web React + Vite | [PLAN] |

## Del documento de arquitectura

| # | Decisión | Por qué | Estado |
|---|---|---|---|
| A1 | Todo gira en torno al **transportista**; nadie entra "suelto" | Resuelve asignación de niños | [PLAN] |
| A2 | Niño → **parada** de una ruta, nunca a un chofer | Choferes/busetas cambian; niños no se "pierden" | [PLAN] |
| A3 | Una cuenta = una persona con teléfono; permisos por vínculos (`memberships`, `guardians`) | Un login, varios roles | [PLAN] |
| A4 | Código de ruta **nunca da acceso solo**; requiere aprobación | Evita que un extraño vea la buseta | [PLAN] |
| A5 | Geocercas en el teléfono del chofer; solo eventos al servidor | Servidor barato con cientos de busetas | [PLAN] |
| A6 | Ubicación por Broadcast; BD guarda muestra cada 30–60 s | No escribir cada punto | [PLAN] |
| A7 | RLS + funciones SQL deciden permisos | Seguro aunque la app falle | [PLAN] |
| A8 | Borrado lógico, UUID, UTC, `operator_id` en todo | Historial y multiempresa | [PLAN] |
| A9 | Orden de paradas manual en beta; OSRM después | Simplicidad | [PLAN] |

## Del repo (RIDY-0001)

| # | Decisión | Por qué | Descartado | Estado |
|---|---|---|---|---|
| R1 | **pnpm únicamente** (`engines.npm`, `.npmrc engine-strict`) | Un solo lockfile | npm (repo arrancó con npm) | [IMPL] |
| R2 | Supabase local en Docker, CLI como devDependency | Mismo schema + seed para todos | Instancia cloud compartida | [IMPL] |
| R3 | Cada dev su BD (opción A); BD de un host por LAN/Tailscale (opción B) | Nadie pisa datos ajenos | Abrir puertos en router | [IMPL] (README) |

## Abiertas

- Marca: confirmar nombre libre en registro de marcas de Costa Rica → hoy `[NOMBRE_PRODUCTO]`. [ABIERTA]
- Monto de tarifa al transportista: [PENDIENTE: ₡ por estudiante activo o fijo] (`subscriptions` dice "por estudiante activo").
- Framework de la web pública: [PENDIENTE].
- Capas del código (ver `convenciones.md`): [PENDIENTE].
