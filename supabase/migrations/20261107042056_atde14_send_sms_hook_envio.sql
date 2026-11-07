-- ATDE-14: el hook send_sms envía el OTP por WhatsApp (Meta Cloud API) vía pg_net.

create or replace function public._meta_wa_otp_body(phone text, otp text, template text)
returns jsonb
language sql
immutable
set search_path = ''
as $$
  select jsonb_build_object(
    'messaging_product', 'whatsapp',
    'to', phone,
    'type', 'template',
    'template', jsonb_build_object(
      'name', template,
      'language', jsonb_build_object('code', 'es'),
      'components', jsonb_build_array(
        jsonb_build_object('type', 'body', 'parameters',
          jsonb_build_array(jsonb_build_object('type', 'text', 'text', otp))),
        jsonb_build_object('type', 'button', 'sub_type', 'url', 'index', '0', 'parameters',
          jsonb_build_array(jsonb_build_object('type', 'text', 'text', otp))))));
$$;

revoke execute on function public._meta_wa_otp_body(text, text, text) from public, anon, authenticated;
grant execute on function public._meta_wa_otp_body(text, text, text) to supabase_auth_admin;

create or replace function public.send_sms_hook(event jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  token text;
  phone_number_id text;
  template text;
begin
  select max(decrypted_secret) filter (where name = 'meta_wa_token'),
         max(decrypted_secret) filter (where name = 'meta_wa_phone_number_id'),
         max(decrypted_secret) filter (where name = 'meta_wa_template')
    into token, phone_number_id, template
    from vault.decrypted_secrets;

  if token is null or phone_number_id is null or template is null then
    return jsonb_build_object('error', jsonb_build_object(
      'http_code', 500, 'message', 'Meta WhatsApp no configurado'));
  end if;

  perform net.http_post(
    url := format('https://graph.facebook.com/v23.0/%s/messages', phone_number_id),
    body := public._meta_wa_otp_body(event->'user'->>'phone', event->'sms'->>'otp', template),
    headers := jsonb_build_object('Content-Type', 'application/json', 'Authorization', 'Bearer ' || token));
  return '{}'::jsonb;
end;
$$;
