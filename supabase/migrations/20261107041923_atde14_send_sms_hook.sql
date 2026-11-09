-- ATDE-14: hook send_sms de Supabase Auth. Sin secretos Meta en Vault responde error.
create extension if not exists pg_net with schema extensions;

create or replace function public.send_sms_hook(event jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  secretos_meta int;
begin
  select count(*) into secretos_meta
  from vault.decrypted_secrets
  where name in ('meta_wa_token', 'meta_wa_phone_number_id', 'meta_wa_template');

  if secretos_meta < 3 then
    return jsonb_build_object('error', jsonb_build_object(
      'http_code', 500, 'message', 'Meta WhatsApp no configurado'));
  end if;
  return '{}'::jsonb;
end;
$$;

grant usage on schema public to supabase_auth_admin;
revoke execute on function public.send_sms_hook(jsonb) from public, anon, authenticated;
grant execute on function public.send_sms_hook(jsonb) to supabase_auth_admin;
