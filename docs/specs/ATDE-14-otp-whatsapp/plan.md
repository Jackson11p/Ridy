# ATDE-14 — Plan

## Módulos

### 1. Migración `send_sms_hook` (`supabase/migrations/<ts>_atde14_send_sms_hook.sql`)
- Crear con `pnpm db:migration atde14_send_sms_hook`. Habilita `pg_net` si no existe.
- Función `public.send_sms_hook(event jsonb) returns jsonb`, `security definer`, `set search_path = ''`, dueño `postgres`.
- Lee de `vault.decrypted_secrets` tres secretos: `meta_wa_token`, `meta_wa_phone_number_id`, `meta_wa_template`.
- Falta alguno → devuelve `{"error":{"http_code":500,"message":"Meta WhatsApp no configurado"}}` sin encolar nada.
- Si están todos → `net.http_post` a `https://graph.facebook.com/v23.0/<phone_number_id>/messages`, header `Authorization: Bearer <token>`, body plantilla de autenticación:
  `messaging_product=whatsapp`, `to=event.user.phone`, `type=template`, `template.name=<meta_wa_template>`, `language.code=es`,
  componentes `body` y `button` (`sub_type=url`, `index="0"`) con `event.sms.otp` como parámetro de texto. Devuelve `{}`.
- Permisos: `revoke execute ... from public, anon, authenticated`; `grant execute ... to supabase_auth_admin`.
- Funciones < 30 líneas: separar armado del body (`public._meta_wa_otp_body(phone text, otp text, template text) returns jsonb`, mismos permisos) del envío.

### 2. Config Auth (`supabase/config.toml`)
- `[auth.sms] enable_signup = true`, `max_frequency = "60s"` (antes `5s`).
- `[auth.sms.test_otp]` con 3 números CR ficticios `5068888000{1..3} = "123456"` (no envían nada).
- `[auth.hook.send_sms] enabled = true`, `uri = "pg-functions://postgres/public/send_sms_hook"`.
- `[auth.rate_limit] sms_sent` se queda en 30/h (beta 1–2 busetas). Twilio sigue `enabled = false`.

### 3. Pruebas pgTAP (`supabase/tests/send-sms-hook.test.sql`)
- Sin secretos → respuesta de error y `net.http_request_queue` sin filas nuevas.
- Con secretos creados en la transacción (`vault.create_secret`) → `{}` y una fila en la cola con URL, header y body esperados (teléfono y código).
- `anon` y `authenticated` sin `execute`; `supabase_auth_admin` con `execute`.
- Todo dentro de `begin … rollback`: no queda secreto ni request.

### 4. Docs
- D8 en `docs/contexto/decisiones.md`: Meta Cloud API directo; SMS respaldo pospuesto a beta; dev con test_otp + número de prueba de Meta ($0).
- `docs/contexto/errores-conocidos.md` punto 7 actualizado; `docs/contexto/arquitectura.md` línea de proveedor OTP.
- README: cargar secretos con `vault.create_secret` (se pierden en `db reset`), crear plantilla de autenticación en Meta, registrar hasta 5 destinatarios, probar.

## Decisiones

- Postgres hook en vez de Edge Function: testeable con pgTAP (ADR-0001), sin Deno ni deps.
- `pg_net` es asíncrono: Auth no sabe si Meta entregó. Aceptable en beta; fallo de entrega se resolverá con respaldo SMS.
- Versión Graph `v23.0` fija en la función; revisar al pasar a producción.
- Migración se aplica con `supabase migration up` (no `db reset`, que borra datos de la BD compartida).
- Ajuste en implementación: dos migraciones (`atde14_send_sms_hook` en T02, `atde14_send_sms_hook_envio` en T03 con `create or replace`), porque la de T02 ya estaba aplicada y no se edita. `net.http_request_queue` (pg_net 0.20.4) sí se lee dentro de la transacción del test; `body` es `bytea` → `convert_from(body, 'utf8')::jsonb`.
- Ajuste en T04: el CLI 2.121 apaga el login por teléfono ("no SMS provider is enabled") aunque el hook esté activo, así que Twilio queda `enabled = true` con valores de relleno no secretos; con el hook activo Auth nunca llama a Twilio. Verificado: `test_otp` no dispara el hook; otro número sí.
