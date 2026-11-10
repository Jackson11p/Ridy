-- ATDE-9-T06: chofer habitual se valida solo si cambia; exige perfil activo (como has_role).
create or replace function private.check_default_driver()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.default_driver_id is not null and not exists (
    select 1 from public.memberships m
    join public.profiles p on p.id = m.profile_id
    where m.profile_id = new.default_driver_id
      and m.operator_id = new.operator_id
      and m.role = 'driver'
      and m.active
      and p.active
  ) then
    raise exception 'default driver must be an active driver of the operator' using errcode = '23514';
  end if;
  return new;
end;
$$;

drop trigger vehicles_check_default_driver on public.vehicles;
create trigger vehicles_check_default_driver_on_insert
  before insert on public.vehicles
  for each row execute function private.check_default_driver();
create trigger vehicles_check_default_driver_on_update
  before update on public.vehicles
  for each row
  when (old.default_driver_id is distinct from new.default_driver_id
    or old.operator_id is distinct from new.operator_id)
  execute function private.check_default_driver();

create index vehicles_default_driver_id_idx on public.vehicles (default_driver_id);
