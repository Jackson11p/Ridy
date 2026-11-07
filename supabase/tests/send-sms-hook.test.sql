-- Hook send_sms de Supabase Auth (ATDE-14). Todo se deshace con rollback:
-- no queda secreto en Vault ni request en la cola de pg_net.
begin;
create extension if not exists pgtap with schema extensions;
select plan(6);

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

select * from finish();
rollback;
