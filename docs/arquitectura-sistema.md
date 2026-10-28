# Ridy — Arquitectura del sistema

Oct 24, 2026 · @Patrick

## Resumen

Ridy gira alrededor del **transportista**: él crea su empresa, sus busetas, sus rutas y sus estudiantes, y desde ahí invita a choferes y padres. Nadie entra "suelto": todo padre y todo chofer pertenece a la operación de un transportista.

Esto resuelve la pregunta clave de cómo se asignan los hijos a los choferes. **El padre nunca elige chofer.** El transportista pone al niño en una ruta, la ruta tiene una buseta y la buseta tiene un chofer. El padre solo confirma que ese niño es suyo.

| Actor | Qué hace | Por dónde entra |
| --- | --- | --- |
| Transportista (dueño) | Administra su empresa: busetas, choferes, rutas, estudiantes y cobros | Se registra en la app y crea su empresa |
| Chofer | Inicia la ruta, marca "Abordó" / "No salió", ve sus paradas | Invitado por el transportista con su número de teléfono |
| Padre o encargado | Ve la buseta en vivo, recibe avisos, marca "Hoy no va" | Invitado por el transportista con su número, o con un código de ruta |
| Admin Ridy (ustedes) | Soporte, alta de transportistas en la beta, facturación de suscripciones | Panel interno |

Muchas veces el transportista **también es el chofer** (como tu tío). En Ridy eso es una sola persona con dos roles en la misma empresa.

## Mapa del sistema

Una sola app (chofer, padres y administración del transportista) habla solo con Supabase; Supabase habla con los servicios externos. La web es pública: landing y directorio de transportistas que aceptan aparecer; no tiene administración.

&#91;embedded content: mapa del sistema · 3 apps, Supabase y servicios externos\]

El teléfono del chofer es la fuente de la verdad en ruta: envía su ubicación al canal en vivo y los eventos (Abordó, cerca de casa) a las Edge Functions, que guardan el registro y mandan el push a los padres.

## Cuentas y roles

Hay **un solo tipo de cuenta: una persona con su número de teléfono**. Lo que puede hacer depende de sus vínculos, no de la app que abra.

- **Login:** número de teléfono + código OTP por **WhatsApp, con SMS como respaldo**. Sin contraseñas, que es lo que menos fricción da a choferes y padres.
- **Membresía en una empresa** (`memberships`): une a una persona con un transportista y le da un rol: `owner` (dueño), `driver` (chofer) o `staff` (oficina). Una persona puede tener varios roles en la misma empresa.
- **Vínculo de encargado** (`guardians`): une a una persona con un estudiante. Un niño puede tener varios encargados (mamá, papá, abuela) y un padre varios hijos.

Al iniciar sesión, la app revisa los vínculos y decide qué mostrar:

1. Solo es encargado → abre la vista de **padre**.
2. Solo es chofer → abre la vista de **chofer**.
3. Es dueño → abre la vista de **chofer** (si maneja) con acceso a **Administrar**.
4. Tiene varios roles (un chofer que también es padre) → un selector arriba para cambiar de vista.
5. No tiene ningún vínculo → pantalla de bienvenida: "Pídele a tu transportista que te invite" o "Tengo un código de ruta" o "Soy transportista".

El teléfono es la llave de todo: si el transportista registró el número de un padre y ese padre inicia sesión con ese número verificado por OTP, el sistema sabe con seguridad quién es.

## Alta del transportista

El transportista se configura una sola vez en unos 15 minutos, y casi todo lo puede hacer desde el celular. En la beta, ustedes lo acompañan en persona.

1. **Crea su cuenta y su empresa:** nombre del negocio, país, moneda y zona horaria. Queda como `owner`.
2. **Registra sus busetas:** placa, capacidad y chofer habitual.
3. **Invita a sus choferes** con nombre y teléfono. Si él mismo maneja, se marca como chofer.
4. **Agrega los colegios** que atiende: nombre y ubicación en el mapa. La geocerca del colegio sale de ese punto.
5. **Crea sus rutas:** una ruta = colegio + buseta + turno (mañana o tarde). Ejemplo: "Colegio San José · Buseta ABC-123 · Mañana".
6. **Carga a sus estudiantes** con nombre, colegio, ruta y el teléfono de al menos un encargado. Puede hacerlo uno por uno o pegando la lista que ya tiene en WhatsApp o Excel.
7. **Ordena las paradas** de cada ruta. Primero a mano (él conoce su recorrido); después Ridy puede sugerir el orden.
8. **Envía las invitaciones:** Ridy manda a cada padre un mensaje con el enlace de descarga.

Regla de oro: el transportista ya tiene toda esta información en su cabeza y en su WhatsApp. El trabajo del producto es que pasarla a Ridy sea más fácil que seguir sin Ridy.

## Cómo entran los padres

Hay dos caminos, y el primero es el principal porque el padre no tiene que hacer nada más que iniciar sesión.

**Camino A — Pre-registro por teléfono (recomendado):**

1. El transportista crea al estudiante "Sofía Mora" y anota el teléfono de la mamá.
2. Ridy guarda una invitación pendiente: *este número es encargado de Sofía*.
3. La mamá recibe el enlace, instala la app e inicia sesión con **ese mismo número** (verificado por OTP).
4. Ridy encuentra la invitación y crea el vínculo automáticamente. Ella ve a Sofía al instante.
5. Solo le falta aceptar el consentimiento de privacidad y confirmar el pin de su casa en el mapa.

**Cambio de dirección:** después de la alta, el padre **propone** el nuevo pin y el transportista lo **aprueba** antes de que cambie la parada.

**Camino B — Código de ruta (respaldo):** sirve cuando el padre usa otro número o llega por su cuenta.

1. Cada ruta tiene un código corto, por ejemplo `RDY-4K7P`, que el transportista puede compartir.
2. El padre ingresa el código y escribe el nombre de su hijo.
3. Queda como **solicitud pendiente**. El transportista recibe un aviso y aprueba o rechaza.
4. Al aprobar, el transportista elige a cuál estudiante corresponde (o lo crea).

El código **nunca da acceso solo**: siempre pasa por la aprobación del transportista. Eso evita que un desconocido con el código vea dónde está la buseta de un niño.

**Segundo encargado:** un padre ya vinculado puede invitar a otro (papá, abuela) con su número, pero esa invitación también la aprueba el transportista. Así se cuida el caso de padres separados.

## Cómo se asignan los hijos a los choferes

Un niño **nunca se asigna directo a un chofer**. Se asigna a una **parada dentro de una ruta**, y el chofer sale de la buseta de esa ruta. La cadena es:

**Estudiante → Parada → Ruta → Buseta → Chofer del día**

- **Parada** (`route_stops`): el niño en una ruta, con su punto de recogida o entrega y su orden. Un niño tiene una parada en la ruta de la mañana y otra en la de la tarde, y pueden estar en lugares distintos (casa por la mañana, casa de la abuela por la tarde).
- **Ruta** (`routes`): colegio + turno + buseta habitual. Es la plantilla fija que se repite cada día de clases.
- **Viaje** (`trips`): la ruta de un día concreto. Se crea solo cada madrugada a partir de la plantilla y es donde se guarda quién manejó, a qué hora salió y quién abordó.
- **Chofer del día:** por defecto, el chofer habitual de la buseta. Si falta, el transportista cambia el chofer **solo en el viaje de hoy**, sin tocar la ruta.

¿Por qué así? Porque los choferes y las busetas cambian (vacaciones, taller, renuncias) y los niños no deberían "perderse" cuando eso pasa. Si el niño cuelga de la ruta, cambiar de chofer es un clic y los padres ni se enteran del cambio, salvo por el aviso "Hoy maneja Carlos, buseta XYZ-789".

| Cambio | Qué toca el transportista | Qué ve el padre |
| --- | --- | --- |
| Niño nuevo | Crea al estudiante y lo pone en una parada | Recibe su invitación |
| Niño se cambia de ruta | Mueve su parada a la otra ruta | Ve la nueva buseta desde el día siguiente |
| Chofer falta hoy | Cambia el chofer del viaje de hoy | Aviso con el nombre del sustituto |
| Buseta en taller | Cambia la buseta del viaje (o de la ruta, si es largo) | Aviso con la placa nueva |
| Niño se retira | Desactiva la parada (no se borra el historial) | Deja de recibir avisos |

## Un día de operación

El día arranca solo: cada madrugada el sistema crea los viajes, y el chofer solo toca dos botones por parada.

&#91;embedded content: turno de la mañana · 8 pasos, un ciclo por parada\]

**Turno de la tarde (PM):** es el mismo ciclo al revés. El chofer inicia la ruta en el colegio y marca "Abordó" a cada niño que sube allí. Luego, en cada parada, la geocerca avisa "cerca de casa" y el chofer marca **"Entregado"**. El viaje se cierra tras la última entrega.

**Lo que nunca debe pasar:** que un padre reciba "llegó al colegio" sin que su hijo haya abordado. Por eso el aviso de llegada solo se envía a los padres de los niños marcados como "Abordó" en ese viaje.

## Tiempo real y notificaciones

El teléfono del chofer hace casi todo el trabajo, y así el servidor se mantiene barato aunque haya cientos de busetas.

**Ubicación:**

- Mientras el viaje está activo, el teléfono del chofer emite su posición cada 5–10 segundos por un canal de **Realtime Broadcast** del viaje (`trip:<id>`). Solo los encargados de ese viaje pueden escuchar ese canal.
- No se escribe en la base de datos en cada punto. Cada 30–60 segundos se guarda una muestra en `location_pings` para el historial, y se borra a los 30 días.
- Si el padre abre el mapa a mitad de ruta, primero ve la última muestra guardada y luego se conecta al canal en vivo.

**Geocercas (en el teléfono del chofer):** la app conoce las próximas paradas y calcula la distancia localmente. Al cruzar un umbral, envía **un evento** al servidor, nunca un flujo continuo.

**Eventos y avisos:**

| Evento | Quién lo dispara | Aviso al padre |
| --- | --- | --- |
| Ruta iniciada | Chofer toca "Iniciar ruta" | "La buseta de Sofía salió" |
| Cerca de casa | Geocerca de 500 m de la parada | "La buseta está a unos 3 minutos" |
| Abordó | Chofer toca "Abordó" | "Sofía abordó a las 6:42" |
| No salió | Chofer toca "No salió" tras esperar | "La buseta pasó y Sofía no salió" |
| Llegó al colegio | Geocerca del colegio | "La buseta de Sofía llegó al colegio" |
| Entregado (tarde) | Chofer toca "Entregado" en la parada | "Sofía fue entregada a las 2:15" |
| Cambio de chofer o buseta | Transportista edita el viaje | "Hoy maneja Carlos, buseta XYZ-789" |

Cada evento se guarda en `attendance` o `trip_events` y una Edge Function manda el push por Expo Notifications. Una tabla `notifications_log` evita mandar el mismo aviso dos veces si el teléfono reintenta.

## Modelo de datos

Toda tabla de operación lleva `operator_id`, y la seguridad (RLS) filtra por él. Las llaves que ve la app son UUID, las fechas se guardan en UTC y nada se borra físicamente: se desactiva.

| Tabla | Qué guarda | Relaciones clave |
| --- | --- | --- |
| `profiles` | Persona: nombre, teléfono, token de push, idioma | 1 a 1 con `auth.users` |
| `operators` | Empresa transportista: nombre, país, moneda, zona horaria, plan | — |
| `memberships` | Rol de una persona en una empresa (`owner`, `driver`, `staff`) | `profiles` ↔ `operators` |
| `vehicles` | Buseta: placa, capacidad, chofer habitual, activa | `operator_id`, `default_driver_id` |
| `schools` | Colegio: nombre, ubicación, radio de geocerca | `operator_id` |
| `routes` | Plantilla: colegio + turno + buseta, código de ruta, activa | `school_id`, `vehicle_id` |
| `students` | Niño: nombre, colegio, activo (sin foto) | `operator_id`, `school_id` |
| `guardians` | Vínculo encargado ↔ estudiante, con relación y si recibe avisos | `profiles` ↔ `students` |
| `invitations` | Invitación pendiente: teléfono, rol o estudiante, quién invitó, vence | `operator_id` |
| `join_requests` | Solicitud por código de ruta, pendiente de aprobación | `route_id`, `profile_id` |
| `route_stops` | Parada: estudiante en una ruta, ubicación, orden, radio de aviso | `route_id`, `student_id` |
| `calendar_days` | Días sin clases por empresa o colegio (feriados, vacaciones) | `operator_id`, `school_id` |
| `trips` | Viaje de un día: ruta, buseta y chofer reales, estado, horas | `route_id`, `vehicle_id`, `driver_id` |
| `attendance` | Estado de cada niño en un viaje: esperado, ausente avisado, abordó, no salió, entregado | `trip_id`, `student_id` |
| `trip_events` | Bitácora del viaje: inicio, geocercas, fin, cambios | `trip_id` |
| `location_pings` | Muestras de ubicación, particionada por mes, purga a 30 días | `trip_id` |
| `notifications_log` | Avisos enviados, para no duplicar | `profile_id`, `trip_id` |
| `subscriptions` | Pago mensual único del transportista a nosotros (sin pagos en la app) | `operator_id` |

El esquema detallado (columnas, índices y políticas) vive en `supabase/migrations/`. Este documento explica el porqué; las migraciones son la fuente de verdad.

## Seguridad y privacidad

Manejamos la ubicación de menores de edad, así que la regla es: **cada persona ve lo mínimo que necesita, y la base de datos lo garantiza aunque la app tenga un error**.

**Quién ve qué (aplicado con RLS en cada tabla):**

| Rol | Ve | No ve |
| --- | --- | --- |
| Padre | Sus hijos, la buseta de sus hijos solo mientras el viaje está activo, el nombre y la placa del chofer | Otros niños, direcciones de otros, el historial de ubicaciones fuera del viaje |
| Chofer | Los niños, paradas y teléfonos de los encargados de los viajes que le tocan hoy | Cobros, otras busetas |
| Dueño / staff | Todo lo de su empresa | Nada de otras empresas |
| Admin Ridy | Datos de soporte, con registro de cada acceso | — |

**Reglas técnicas:**

- RLS activado en todas las tablas desde la migración que las crea, con pruebas automáticas en el CI (`test-rls`).
- Las escrituras sensibles (aprobar solicitudes, mover estudiantes, cambiar chofer) pasan por funciones SQL que validan el rol, no por inserts directos.
- Los canales de Realtime son privados: el servidor revisa que quien escucha sea encargado de un niño de ese viaje.
- La llave `service_role` solo vive en Edge Functions, nunca en la app ni en el repo.

**Privacidad de menores (Ley 8968 de Costa Rica):**

- Consentimiento explícito del encargado antes de ver o guardar cualquier dato del niño.
- Datos mínimos del niño: nombre y colegio. **Sin fotos**, fechas de nacimiento, cédulas ni datos médicos.
- Historial de ubicaciones borrado a los 30 días; asistencia conservada mientras el niño esté activo.
- El encargado puede pedir que se borren sus datos y los de su hijo desde la app.

## Casos especiales

Estos casos pasan en la vida real desde la primera semana; el diseño ya los contempla.

| Caso | Cómo lo resuelve Ridy |
| --- | --- |
| Padres separados | Cada uno es encargado por separado. Agregar un encargado requiere aprobación del transportista; quitarlo, también. |
| Dos direcciones (mañana en casa, tarde donde la abuela) | El niño tiene una parada distinta en la ruta AM y en la PM. |
| Hermanos en la misma buseta | Cada uno tiene su parada; si comparten punto, el chofer los ve agrupados y puede marcar "Abordaron todos". |
| "Hoy no va" tarde | Se acepta hasta que el chofer inicia la ruta. Después, el padre ve "Avísale al chofer" con un botón de llamada. |
| Cambio de dirección | El padre propone el nuevo pin; el transportista aprueba o rechaza. |
| "Hoy no va" varios días | El padre elige un rango (enfermo hasta el viernes). |
| Chofer sustituto | El transportista cambia el chofer del viaje de hoy; los padres reciben el aviso con su nombre. |
| Buseta varada | El chofer toca "Reportar problema"; los padres reciben "La buseta tuvo un inconveniente, el transportista te contactará". |
| Teléfono del chofer sin señal | Si no hay posición en 2 minutos, el mapa muestra "Última ubicación hace X min" en vez de una posición falsa. Los eventos se guardan en el teléfono y se envían al recuperar señal. |
| Chofer olvida iniciar la ruta | A la hora habitual + 10 min sin iniciar, recordatorio al chofer y aviso al transportista. |
| Chofer olvida finalizar | El viaje se cierra solo al llegar al colegio (AM) o tras la última entrega (PM), con aviso. |
| Feriados y vacaciones | `calendar_days` evita crear viajes y avisos esos días. |
| Padre sin smartphone | Fuera del MVP. Más adelante: avisos por SMS o WhatsApp al número registrado. |

## Estructura del repo

Un monorepo con pnpm: una app móvil con todos los roles (incluida la administración), una web pública y el backend en Supabase.

```
ridy/
├─ .github/
│  ├─ CODEOWNERS
│  └─ workflows/ci.yml           typecheck · lint · test-rls · build
├─ apps/
│  ├─ mobile/                    Expo (React Native) + TypeScript
│  │  ├─ app/
│  │  │  ├─ (auth)/              login, OTP, consentimiento, bienvenida
│  │  │  ├─ (parent)/            inicio, mapa en vivo, historial, perfil
│  │  │  ├─ (driver)/            hoy, modo conducción, paradas
│  │  │  └─ (manage)/            administrar desde el celular (dueño)
│  │  └─ src/
│  │     ├─ features/            location, geofence, attendance, invites…
│  │     ├─ components/          Button, Card, StatusBadge, StudentRow…
│  │     ├─ services/            acceso a Supabase (consultas y RPC)
│  │     ├─ theme/  i18n/
│  └─ web/                       web pública: landing y directorio (framework por definir)
├─ packages/
│  └─ shared/                    tipos generados de Supabase, validaciones (zod), utilidades
├─ supabase/
│  ├─ migrations/                esquema, RLS y funciones SQL (fuente de verdad)
│  ├─ functions/                 Edge Functions: notify, accept-invite, create-daily-trips…
│  ├─ tests/                     pruebas de RLS y funciones
│  └─ seed.sql                   datos de ejemplo para desarrollo
├─ docs/                         decisiones de arquitectura (ADR)
├─ .gitignore
└─ package.json
```

**Convenciones:**

- Código, tablas y nombres técnicos en inglés; textos de la app en español e inglés vía i18n.
- Cada cambio de base de datos es una migración nueva; nunca se edita una migración ya aplicada.
- La app no decide permisos: los pregunta a la base de datos (RLS y funciones SQL).
- Cada decisión grande (por qué Supabase, por qué geocercas en el teléfono) queda en un archivo corto en `docs/`.

## Plan de construcción por fases

Están en la fase 0. Cada fase se cierra cuando se cumple su prueba real, no cuando se acaba una lista de funciones.

&#91;embedded content: plan por fases · 4 fases, cada una con su condición de salida\]

**Orden de trabajo dentro de la fase 0 y 1:**

1. Migración inicial: empresas, membresías, colegios, busetas, rutas, estudiantes, encargados e invitaciones, con RLS y pruebas.
2. Login por teléfono y la lógica de "¿qué vista le muestro?" según los vínculos.
3. Alta del transportista desde el celular (empresa, buseta, ruta, estudiantes).
4. Invitación de padres por teléfono y su vinculación automática.
5. Viajes diarios automáticos, "Iniciar ruta", ubicación en vivo y "Abordó / No salió".
6. Avisos push: salida, cerca de casa, abordó y llegada al colegio.
7. "Hoy no va" y el salto de paradas.
8. Prueba real con la buseta de tu tío.

## Decisiones abiertas

Estas preguntas cambian partes del diseño; conviene cerrarlas entre los dos antes de la fase que las necesita.

- [x] **¿Quién paga?** → **Cerrada:** B2B2C. Los padres le pagan al transportista con nuestra tarifa incluida; el transportista nos hace un solo pago mensual. Sin pagos dentro de la app.
  - Pregunta original: ¿El transportista (₡ por estudiante, y él lo traslada a los padres) o cada padre directo? Define si hay pagos dentro de la app y la comisión de las tiendas. Recomendación: el transportista.
- [x] **¿El chofer puede ver el teléfono de los padres?** → **Cerrada:** sí, ve el teléfono de los encargados.
  - Pregunta original: O solo un botón "Llamar" que no muestra el número.
- [x] **¿Hasta qué hora vale "Hoy no va"?** → **Cerrada:** hasta que el chofer inicia la ruta.
  - Pregunta original: Propuesta: hasta que el chofer inicia la ruta.
- [x] **¿El padre puede editar su pin en el mapa?** → **Cerrada:** el padre propone el cambio y el transportista lo aprueba.
  - Pregunta original: ¿El padre puede editar su pin en el mapa o el cambio de dirección lo aprueba el transportista?
- [x] **¿Foto del niño sí o no?** → **Cerrada:** no, sin fotos de los niños.
  - Pregunta original: Ayuda al chofer sustituto, pero es un dato más que cuidar.
- [x] **¿SMS o WhatsApp para el OTP?** → **Cerrada:** WhatsApp, con SMS como respaldo. Falta elegir proveedor.
  - Pregunta original: WhatsApp suele salir más barato en la región; hay que comparar proveedores.
- [x] **¿El panel web del transportista entra en la beta?** → **Cerrada:** no hay panel web; toda la administración vive en la app. La web es pública (landing y directorio de transportistas que aceptan aparecer).
  - Pregunta original: ¿El panel web del transportista entra en la beta o todo se administra desde el celular al inicio?
- [ ] **Marca:** confirmar que "Ridy" esté libre en el registro de marcas de Costa Rica antes de invertir en diseño.
