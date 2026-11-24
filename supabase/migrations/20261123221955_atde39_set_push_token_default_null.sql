-- ATDE-39-T06: set_push_token() sin argumento borra el token. El generador de tipos marca `token` como string no nulo;
-- con default null queda opcional y la app borra sin forzar tipos. Mismo cuerpo; permisos se conservan.
create or replace function public.set_push_token(token text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller uuid := (select auth.uid());
begin
  if caller is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;
  if not exists (select 1 from public.profiles where id = caller and active) then
    raise exception 'inactive profile' using errcode = '42501';
  end if;

  update public.profiles set push_token = null
  where push_token = set_push_token.token and id <> caller;
  update public.profiles set push_token = set_push_token.token where id = caller;
end;
$$;
