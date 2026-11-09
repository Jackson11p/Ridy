-- ATDE-9-T03: rutas (routes) colegio + turno + buseta de la misma empresa, con código RDY- generado.
create type public.route_shift as enum ('am', 'pm');

-- Alfabeto de 32 símbolos sin ambiguos (sin 0/O/1/I): 256 % 32 = 0, sin sesgo por byte.
create function private.generate_route_code()
returns text
language sql
volatile
set search_path = ''
as $$
  select 'RDY-' || string_agg(
    substr('23456789ABCDEFGHJKLMNPQRSTUVWXYZ', get_byte(r.bytes, i) % 32 + 1, 1), '' order by i
  )
  from (select extensions.gen_random_bytes(6) as bytes) r, generate_series(0, 5) as i;
$$;
revoke execute on function private.generate_route_code() from public, anon;
grant execute on function private.generate_route_code() to authenticated;

create table public.routes (
  id uuid primary key default gen_random_uuid(),
  operator_id uuid not null references public.operators (id),
  school_id uuid not null,
  vehicle_id uuid not null,
  shift public.route_shift not null,
  code text not null unique default private.generate_route_code()
    check (code ~ '^RDY-[A-Z0-9]{6}$'),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (school_id, operator_id) references public.schools (id, operator_id),
  foreign key (vehicle_id, operator_id) references public.vehicles (id, operator_id)
);
alter table public.routes enable row level security;
create index routes_operator_id_idx on public.routes (operator_id);
create index routes_school_id_idx on public.routes (school_id);
create index routes_vehicle_id_idx on public.routes (vehicle_id);

create trigger routes_set_updated_at
  before update on public.routes
  for each row execute function private.set_updated_at();

-- Clientes: sin delete; el código lo pone la BD y nunca se edita.
revoke all on public.routes from anon, authenticated;
grant select on public.routes to authenticated;
grant insert (operator_id, school_id, vehicle_id, shift, active) on public.routes to authenticated;
grant update (school_id, vehicle_id, shift, active) on public.routes to authenticated;

create policy "owner/staff ven rutas de su empresa" on public.routes
  for select to authenticated
  using (private.has_role(operator_id, '{owner,staff}'));
create policy "owner/staff crean rutas en su empresa" on public.routes
  for insert to authenticated
  with check (private.has_role(operator_id, '{owner,staff}'));
create policy "owner/staff editan rutas de su empresa" on public.routes
  for update to authenticated
  using (private.has_role(operator_id, '{owner,staff}'))
  with check (private.has_role(operator_id, '{owner,staff}'));

-- Chofer: hoy, rutas de la buseta de la que es chofer habitual (con trips se amplía).
-- Sin ciclos de RLS: vehicles <- routes <- schools.
create policy "chofer ve rutas activas de su buseta" on public.routes
  for select to authenticated
  using (
    active
    and private.has_role(operator_id, '{driver}')
    and exists (
      select 1 from public.vehicles v
      where v.id = routes.vehicle_id
        and v.active
        and v.default_driver_id = (select auth.uid())
    )
  );
create policy "chofer ve colegios activos de sus rutas" on public.schools
  for select to authenticated
  using (
    active
    and private.has_role(operator_id, '{driver}')
    and exists (
      select 1 from public.routes r
      where r.school_id = schools.id
        and r.active
        and exists (
          select 1 from public.vehicles v
          where v.id = r.vehicle_id
            and v.active
            and v.default_driver_id = (select auth.uid())
        )
    )
  );
