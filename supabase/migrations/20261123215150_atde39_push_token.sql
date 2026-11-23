-- ATDE-39-T01: token push solo por set_push_token; un teléfono = un dueño del token.
-- security definer: quita el token del perfil anterior (otra persona en el mismo teléfono) sin dar update sobre perfiles ajenos.
alter table public.profiles add constraint profiles_push_token_format check (
  push_token is null
  or (push_token ~ '^Expo(nent)?PushToken\[[^\]]+\]$' and length(push_token) <= 255)
);

revoke update (push_token) on public.profiles from authenticated;

create function public.set_push_token(token text)
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
revoke execute on function public.set_push_token(text) from public, anon;
grant execute on function public.set_push_token(text) to authenticated;
