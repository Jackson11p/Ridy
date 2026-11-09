-- ATDE-14: solo Supabase Auth ejecuta el hook; service_role tampoco (review MENOR-1).
revoke execute on function public.send_sms_hook(jsonb) from service_role;
revoke execute on function public._meta_wa_otp_body(text, text, text) from service_role;
