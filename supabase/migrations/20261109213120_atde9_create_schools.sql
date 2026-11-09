-- ATDE-9-T02: colegios (schools) con punto geográfico y radio de geocerca.
create table public.schools (
  id uuid primary key default gen_random_uuid(),
  operator_id uuid not null references public.operators (id),
  name text not null check (length(trim(name)) > 0),
  location extensions.geography(Point, 4326) not null,
  geofence_radius_m int not null default 200 check (geofence_radius_m between 50 and 2000),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, operator_id)
);
alter table public.schools enable row level security;
create index schools_operator_id_idx on public.schools (operator_id);
create index schools_location_idx on public.schools using gist (location);

create trigger schools_set_updated_at
  before update on public.schools
  for each row execute function private.set_updated_at();

-- Clientes: sin delete; update nunca toca id, operator_id ni fechas.
revoke all on public.schools from anon, authenticated;
grant select on public.schools to authenticated;
grant insert (operator_id, name, location, geofence_radius_m, active) on public.schools to authenticated;
grant update (name, location, geofence_radius_m, active) on public.schools to authenticated;

create policy "owner/staff ven colegios de su empresa" on public.schools
  for select to authenticated
  using (private.has_role(operator_id, '{owner,staff}'));
create policy "owner/staff crean colegios en su empresa" on public.schools
  for insert to authenticated
  with check (private.has_role(operator_id, '{owner,staff}'));
create policy "owner/staff editan colegios de su empresa" on public.schools
  for update to authenticated
  using (private.has_role(operator_id, '{owner,staff}'))
  with check (private.has_role(operator_id, '{owner,staff}'));
