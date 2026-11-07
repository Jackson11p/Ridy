-- Hook send_sms de Supabase Auth (ATDE-14). Todo se deshace con rollback:
-- no queda secreto en Vault ni request en la cola de pg_net.
begin;
create extension if not exists pgtap with schema extensions;
select plan(13);

-- Permisos: solo Supabase Auth ejecuta el hook
select function_privs_are('public', 'send_sms_hook', array['jsonb'], 'anon', array[]::text[],
  'anon no ejecuta el hook');
select function_privs_are('public', 'send_sms_hook', array['jsonb'], 'authenticated', array[]::text[],
  'authenticated no ejecuta el hook');
select function_privs_are('public', 'send_sms_hook', array['jsonb'], 'supabase_auth_admin', array['EXECUTE'],
  'supabase_auth_admin ejecuta el hook');
select is_definer('public', 'send_sms_hook', array['jsonb'], 'hook es security definer');

-- Sin secretos Meta: error claro y nada encolado
delete from vault.secrets where name in ('meta_wa_token', 'meta_wa_phone_number_id', 'meta_wa_template');
create temp table cola_antes as select count(*) as n from net.http_request_queue;

select is(
  public.send_sms_hook('{"user":{"phone":"50688887777"},"sms":{"otp":"654321"}}'::jsonb),
  '{"error":{"http_code":500,"message":"Meta WhatsApp no configurado"}}'::jsonb,
  'sin secretos responde error 500');
select is((select count(*) from net.http_request_queue), (select n from cola_antes),
  'sin secretos no encola request');

-- Armado del body: interno, nadie más lo ejecuta
select function_privs_are('public', '_meta_wa_otp_body', array['text', 'text', 'text'], 'anon', array[]::text[],
  'anon no ejecuta el armado del body');
select function_privs_are('public', '_meta_wa_otp_body', array['text', 'text', 'text'], 'authenticated', array[]::text[],
  'authenticated no ejecuta el armado del body');

-- Con secretos (falsos, solo en esta transacción): encola el POST a Meta
select vault.create_secret('token-falso', 'meta_wa_token');
select vault.create_secret('111222333', 'meta_wa_phone_number_id');
select vault.create_secret('ridy_otp', 'meta_wa_template');

select is(
  public.send_sms_hook('{"user":{"phone":"50688887777"},"sms":{"otp":"654321"}}'::jsonb),
  '{}'::jsonb,
  'con secretos responde vacío');
select is((select count(*) from net.http_request_queue), (select n from cola_antes) + 1,
  'con secretos encola un request');

create temp table enviado as
  select url, headers, convert_from(body, 'utf8')::jsonb as body
  from net.http_request_queue order by id desc limit 1;

select is((select url from enviado), 'https://graph.facebook.com/v23.0/111222333/messages',
  'POST al phone_number_id de Meta');
select is((select headers->>'Authorization' from enviado), 'Bearer token-falso',
  'header Authorization con el token');
select is((select body from enviado), '{
  "messaging_product": "whatsapp", "to": "50688887777", "type": "template",
  "template": {"name": "ridy_otp", "language": {"code": "es"}, "components": [
    {"type": "body", "parameters": [{"type": "text", "text": "654321"}]},
    {"type": "button", "sub_type": "url", "index": "0", "parameters": [{"type": "text", "text": "654321"}]}
  ]}}'::jsonb,
  'body de plantilla de autenticación con teléfono y código');

select * from finish();
rollback;
