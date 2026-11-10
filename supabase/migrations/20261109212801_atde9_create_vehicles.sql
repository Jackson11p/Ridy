-- ATDE-9-T01: PostGIS y busetas (vehicles) con chofer habitual válido.
create extension if not exists postgis with schema extensions;

create table public.vehicles (
  id uuid primary key default gen_random_uuid(),
  operator_id uuid not null references public.operators (id),
  plate text not null check (length(trim(plate)) > 0),
  capacity int not null check (capacity between 1 and 60),
  default_driver_id uuid references public.profiles (id),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (operator_id, plate),
  unique (id, operator_id)
);
alter table public.vehicles enable row level security;

create trigger vehicles_set_updated_at
  before update on public.vehicles
  for each row execute function private.set_updated_at();

-- security definer: valida contra memberships sin depender del RLS del que escribe.
create function private.check_default_driver()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.default_driver_id is not null and not exists (
    select 1 from public.memberships m
    where m.profile_id = new.default_driver_id
      and m.operator_id = new.operator_id
      and m.role = 'driver'
      and m.active
  ) then
    raise exception 'default driver must be an active driver of the operator' using errcode = '23514';
  end if;
  return new;
end;
$$;
revoke execute on function private.check_default_driver() from public;

create trigger vehicles_check_default_driver
  before insert or update of default_driver_id, operator_id on public.vehicles
  for each row execute function private.check_default_driver();

-- Clientes: sin delete; update nunca toca id, operator_id ni fechas.
revoke all on public.vehicles from anon, authenticated;
grant select on public.vehicles to authenticated;
grant insert (operator_id, plate, capacity, default_driver_id, active) on public.vehicles to authenticated;
grant update (plate, capacity, default_driver_id, active) on public.vehicles to authenticated;

create policy "owner/staff ven busetas de su empresa" on public.vehicles
  for select to authenticated
  using (private.has_role(operator_id, '{owner,staff}'));
create policy "owner/staff crean busetas en su empresa" on public.vehicles
  for insert to authenticated
  with check (private.has_role(operator_id, '{owner,staff}'));
create policy "owner/staff editan busetas de su empresa" on public.vehicles
  for update to authenticated
  using (private.has_role(operator_id, '{owner,staff}'))
  with check (private.has_role(operator_id, '{owner,staff}'));
create policy "chofer ve su buseta activa" on public.vehicles
  for select to authenticated
  using (
    active
    and default_driver_id = (select auth.uid())
    and private.has_role(operator_id, '{driver}')
  );
