# ATDE-14 — Tareas

- [x] ATDE-14-T01 Docs de decisión: D8, errores-conocidos punto 7, arquitectura (proveedor OTP)
  - D8 [IMPL] local con Meta Cloud API; punto 7 y "Qué NO existe" actualizados
- [ ] ATDE-14-T02 Test pgTAP de permisos y respuesta de error sin secretos (rojo) → migración `send_sms_hook` mínima (verde)
- [ ] ATDE-14-T03 Test pgTAP de envío con secretos: fila en `net.http_request_queue` con URL, header y body (rojo) → envío por `pg_net` (verde)
- [ ] ATDE-14-T04 `config.toml`: `enable_signup`, `max_frequency = "60s"`, `test_otp`, `[auth.hook.send_sms]`; verificar login con número de prueba vía API local
- [ ] ATDE-14-T05 README: cargar secretos Meta en Vault, plantilla de autenticación, prueba con número real
