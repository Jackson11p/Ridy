-- ATDE-8-T05: el teléfono del perfil sigue al de auth.users (llave de identidad).
create function private.handle_user_phone_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.profiles set phone = new.phone where id = new.id;
  return new;
end;
$$;
revoke execute on function private.handle_user_phone_change() from public;

create trigger on_auth_user_phone_changed
  after update of phone on auth.users
  for each row
  when (old.phone is distinct from new.phone)
  execute function private.handle_user_phone_change();
