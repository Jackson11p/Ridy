# ATDE-14 — Tareas

- [x] ATDE-14-T01 Docs de decisión: D8, errores-conocidos punto 7, arquitectura (proveedor OTP)
  - D8 [IMPL] local con Meta Cloud API; punto 7 y "Qué NO existe" actualizados
- [x] ATDE-14-T02 Test pgTAP de permisos y respuesta de error sin secretos (rojo) → migración `send_sms_hook` mínima (verde)
  - Rojo: 6/6 fallan (`send_sms_hook(jsonb) does not exist`, `net.http_request_queue` no existe). Verde: `pnpm test:db` 11/11
- [x] ATDE-14-T03 Test pgTAP de envío con secretos: fila en `net.http_request_queue` con URL, header y body (rojo) → envío por `pg_net` (verde)
  - Rojo: 6/13 fallan (`_meta_wa_otp_body` no existe; cola have 0 want 1). Verde: `pnpm test:db` 18/18; cola y Vault quedan en 0 tras rollback
- [x] ATDE-14-T04 `config.toml`: `enable_signup`, `max_frequency = "60s"`, `test_otp`, `[auth.hook.send_sms]`; verificar login con número de prueba vía API local
  - Sin proveedor: `phone_provider_disabled`. Con Twilio de relleno: `/otp` 50688880001 → `message_id: test-otp`, `/verify` → sesión bearer; 50688887777 sin secretos → 500 "Meta WhatsApp no configurado"; con secretos falsos → `{}` y Meta responde 401 en `net._http_response`
- [x] ATDE-14-T05 README: cargar secretos Meta en Vault, plantilla de autenticación, prueba con número real
  - Sección "Login por teléfono (OTP por WhatsApp)"; prueba con número real queda manual (spec)
- [x] ATDE-14-T06 (review MENOR-1) Test: `service_role` y `public` sin `execute` en ambas funciones (rojo) → migración que revoca a `service_role` (verde)
  - Rojo: 2/17 fallan (`service_role` Extra privileges: EXECUTE en hook y body). Verde: `pnpm test:db` 22/22
- [x] ATDE-14-T07 (review MENOR-2) Test: `phone` u `otp` nulo/vacío → error 400 sin encolar (rojo) → validación en el hook (verde); conteo de cola filtrado por URL de prueba (NOTA-3)
  - Rojo: 5/21 fallan (have `{}` want 400; cola have 3 want 0). Verde: `pnpm test:db` 26/26; conteos filtrados por `graph.facebook.com` / URL `111222333`
- [x] ATDE-14-T08 (review MENOR-3) errores-conocidos punto 7: `config.toml` (Twilio de relleno + hook) no se empuja tal cual al remoto; revisar en ticket de beta
  - Nota añadida al final del punto 7
