-- Hook send_sms de Supabase Auth (ATDE-14). Todo se deshace con rollback:
-- no queda secreto en Vault ni request en la cola de pg_net.
-- Conteos de cola filtrados por URL: otras sesiones pueden encolar a la vez.
begin;
create extension if not exists pgtap with schema extensions;
select plan(21);

-- Permisos: solo Supabase Auth ejecuta el hook
select function_privs_are('public', 'send_sms_hook', array['jsonb'], 'anon', array[]::text[],
  'anon no ejecuta el hook');
select function_privs_are('public', 'send_sms_hook', array['jsonb'], 'authenticated', array[]::text[],
  'authenticated no ejecuta el hook');
select function_privs_are('public', 'send_sms_hook', array['jsonb'], 'supabase_auth_admin', array['EXECUTE'],
  'supabase_auth_admin ejecuta el hook');
select function_privs_are('public', 'send_sms_hook', array['jsonb'], 'service_role', array[]::text[],
  'service_role no ejecuta el hook');
select function_privs_are('public', 'send_sms_hook', array['jsonb'], 'public', array[]::text[],
  'public no ejecuta el hook');
select is_definer('public', 'send_sms_hook', array['jsonb'], 'hook es security definer');

-- Armado del body: interno, nadie más lo ejecuta
select function_privs_are('public', '_meta_wa_otp_body', array['text', 'text', 'text'], 'anon', array[]::text[],
  'anon no ejecuta el armado del body');
select function_privs_are('public', '_meta_wa_otp_body', array['text', 'text', 'text'], 'authenticated', array[]::text[],
  'authenticated no ejecuta el armado del body');
select function_privs_are('public', '_meta_wa_otp_body', array['text', 'text', 'text'], 'service_role', array[]::text[],
  'service_role no ejecuta el armado del body');
select function_privs_are('public', '_meta_wa_otp_body', array['text', 'text', 'text'], 'public', array[]::text[],
  'public no ejecuta el armado del body');

-- Sin secretos Meta: error claro y nada encolado hacia Meta
delete from vault.secrets where name in ('meta_wa_token', 'meta_wa_phone_number_id', 'meta_wa_template');
create temp table cola_meta_antes as
  select count(*) as n from net.http_request_queue where url like 'https://graph.facebook.com/%';

select is(
  public.send_sms_hook('{"user":{"phone":"50688887777"},"sms":{"otp":"654321"}}'::jsonb),
  '{"error":{"http_code":500,"message":"Meta WhatsApp no configurado"}}'::jsonb,
  'sin secretos responde error 500');
select is(
  (select count(*) from net.http_request_queue where url like 'https://graph.facebook.com/%'),
  (select n from cola_meta_antes),
  'sin secretos no encola request');

-- Con secretos (falsos, solo en esta transacción). URL de prueba única: 111222333
select vault.create_secret('token-falso', 'meta_wa_token');
select vault.create_secret('111222333', 'meta_wa_phone_number_id');
select vault.create_secret('ridy_otp', 'meta_wa_template');
create temp table cola_prueba_antes as
  select count(*) as n from net.http_request_queue
  where url = 'https://graph.facebook.com/v23.0/111222333/messages';
create temp view cola_prueba_nuevas as
  select (select count(*) from net.http_request_queue
          where url = 'https://graph.facebook.com/v23.0/111222333/messages')
       - (select n from cola_prueba_antes) as n;

-- Evento incompleto: error 400 y nada encolado
select is(public.send_sms_hook('{"user":{},"sms":{"otp":"654321"}}'::jsonb),
  '{"error":{"http_code":400,"message":"Falta teléfono o código OTP"}}'::jsonb,
  'sin teléfono responde error 400');
select is(public.send_sms_hook('{"user":{"phone":""},"sms":{"otp":"654321"}}'::jsonb),
  '{"error":{"http_code":400,"message":"Falta teléfono o código OTP"}}'::jsonb,
  'teléfono vacío responde error 400');
select is(public.send_sms_hook('{"user":{"phone":"50688887777"},"sms":{"otp":""}}'::jsonb),
  '{"error":{"http_code":400,"message":"Falta teléfono o código OTP"}}'::jsonb,
  'código vacío responde error 400');
select is((select n from cola_prueba_nuevas), 0::bigint, 'evento incompleto no encola request');

-- Evento válido: encola el POST a Meta
select is(
  public.send_sms_hook('{"user":{"phone":"50688887777"},"sms":{"otp":"654321"}}'::jsonb),
  '{}'::jsonb,
  'con secretos responde vacío');
select is((select n from cola_prueba_nuevas), 1::bigint, 'con secretos encola un request');

create temp table enviado as
  select headers, convert_from(body, 'utf8')::jsonb as body
  from net.http_request_queue
  where url = 'https://graph.facebook.com/v23.0/111222333/messages'
  order by id desc limit 1;

select is((select headers->>'Authorization' from enviado), 'Bearer token-falso',
  'header Authorization con el token');
select is((select headers->>'Content-Type' from enviado), 'application/json',
  'header Content-Type JSON');
select is((select body from enviado), '{
  "messaging_product": "whatsapp", "to": "50688887777", "type": "template",
  "template": {"name": "ridy_otp", "language": {"code": "es"}, "components": [
    {"type": "body", "parameters": [{"type": "text", "text": "654321"}]},
    {"type": "button", "sub_type": "url", "index": "0", "parameters": [{"type": "text", "text": "654321"}]}
  ]}}'::jsonb,
  'body de plantilla de autenticación con teléfono y código');

select * from finish();
rollback;
