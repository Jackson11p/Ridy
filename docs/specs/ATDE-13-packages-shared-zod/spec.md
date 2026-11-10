# ATDE-13 — packages/shared: tipos de Supabase y validaciones zod

## Problema
La constitución (§6) exige validar datos en cada límite, pero no hay un lugar común para los tipos de la BD ni para las validaciones. Cada pantalla o Edge Function escribiría los suyos y se desalinearían con el esquema.

## Objetivo
Un paquete `packages/shared` del que la app (y luego las Edge Functions) toman los mismos tipos generados del esquema y los mismos esquemas de validación.

## Criterios de aceptación
1. Un script de raíz regenera los tipos de Supabase desde la BD local y los deja en `packages/shared`.
2. `apps/mobile` importa tipos y esquemas como `@ridy/shared`, sin rutas relativas entre paquetes.
3. Primer esquema zod: teléfono, con test unitario (casos válidos, inválidos y normalización).
4. CI falla si los tipos generados no coinciden con las migraciones.
5. `pnpm typecheck`, `pnpm lint`, `pnpm test` y el build de CI siguen en verde.

## Fuera de alcance
- Otros esquemas (estudiantes, rutas…), Edge Functions, cliente Supabase en `services/`, pantalla de login.

## Supuestos
- Ticket Jira `ATDE-13`; rama y carpeta `ATDE-13-packages-shared-zod`; tareas `ATDE-13-Tnn`.
- `zod` ^4 aprobado por el usuario (2026-11-10), solo en `packages/shared`; se anota en constitución §2.
- Teléfono en formato internacional E.164 (Supabase Auth lo usa así): se aceptan espacios, guiones y paréntesis, se quitan, y queda `+` + 8–15 dígitos sin cero inicial. Sin reglas por país (beta en Costa Rica, `506` + 8 dígitos cabe).
- Paquete sin build: se consume el TypeScript fuente (Metro y jest lo transforman). Sin deps nuevas aparte de zod; versiones de `typescript`/`jest` iguales a las ya aprobadas.
- El chequeo de tipos desactualizados va como paso del job `test-rls` (ya levanta la BD y es obligatorio en la rama).
