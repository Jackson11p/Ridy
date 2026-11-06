-- ATDE-8-T07: perfil inactivo no tiene roles ni crea empresas; timezone válida.
revoke execute on function private.set_updated_at() from public;

create or replace function private.has_role(op uuid, roles public.membership_role[])
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.memberships m
    join public.profiles p on p.id = m.profile_id
    where m.operator_id = op
      and m.profile_id = (select auth.uid())
      and m.active
      and p.active
      and m.role = any (roles)
  );
$$;

create or replace function public.create_operator(
  name text, country text, currency text, timezone text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller uuid := (select auth.uid());
  new_id uuid;
begin
  if caller is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;
  if not exists (select 1 from public.profiles where id = caller and active) then
    raise exception 'inactive profile' using errcode = '42501';
  end if;
  if not exists (select 1 from pg_catalog.pg_timezone_names where pg_timezone_names.name = create_operator.timezone) then
    raise exception 'invalid timezone: %', create_operator.timezone using errcode = '22023';
  end if;

  insert into public.operators (name, country, currency, timezone)
  values (create_operator.name, create_operator.country, create_operator.currency, create_operator.timezone)
  returning id into new_id;

  insert into public.memberships (profile_id, operator_id, role)
  values (caller, new_id, 'owner');

  return new_id;
end;
$$;
