-- ATDE-14: el hook rechaza eventos sin teléfono o sin código (review MENOR-2).
-- create or replace conserva los permisos ya otorgados/revocados.
create or replace function public.send_sms_hook(event jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  phone text := nullif(event->'user'->>'phone', '');
  otp text := nullif(event->'sms'->>'otp', '');
  token text;
  phone_number_id text;
  template text;
begin
  if phone is null or otp is null then
    return '{"error":{"http_code":400,"message":"Falta teléfono o código OTP"}}'::jsonb;
  end if;

  select max(decrypted_secret) filter (where name = 'meta_wa_token'),
         max(decrypted_secret) filter (where name = 'meta_wa_phone_number_id'),
         max(decrypted_secret) filter (where name = 'meta_wa_template')
    into token, phone_number_id, template
    from vault.decrypted_secrets;

  if token is null or phone_number_id is null or template is null then
    return '{"error":{"http_code":500,"message":"Meta WhatsApp no configurado"}}'::jsonb;
  end if;

  perform net.http_post(
    url := format('https://graph.facebook.com/v23.0/%s/messages', phone_number_id),
    body := public._meta_wa_otp_body(phone, otp, template),
    headers := jsonb_build_object('Content-Type', 'application/json', 'Authorization', 'Bearer ' || token));
  return '{}'::jsonb;
end;
$$;
