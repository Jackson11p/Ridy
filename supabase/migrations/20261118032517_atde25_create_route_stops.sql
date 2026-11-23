-- ATDE-25-T01: paradas (route_stops): estudiante en una ruta, con punto, orden y radio de aviso.
-- Dirección de un menor: solo el punto, sin texto ni notas (datos mínimos, Ley 8968).
alter table public.routes add unique (id, operator_id);

create table public.route_stops (
  id uuid primary key default gen_random_uuid(),
  operator_id uuid not null references public.operators (id),
  route_id uuid not null,
  student_id uuid not null,
  location extensions.geography(Point, 4326) not null,
  stop_order int not null check (stop_order > 0),
  notify_radius_m int not null default 500 check (notify_radius_m between 100 and 2000),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (route_id, operator_id) references public.routes (id, operator_id),
  foreign key (student_id, operator_id) references public.students (id, operator_id)
);
alter table public.route_stops enable row level security;
-- Una parada activa por niño y ruta; las desactivadas quedan como historial.
create unique index route_stops_active_student_route_idx
  on public.route_stops (route_id, student_id) where active;
create index route_stops_operator_id_idx on public.route_stops (operator_id);
create index route_stops_student_id_idx on public.route_stops (student_id);
create index route_stops_location_idx on public.route_stops using gist (location);

create trigger route_stops_set_updated_at
  before update on public.route_stops
  for each row execute function private.set_updated_at();

-- Clientes: sin delete; ruta y estudiante fijos (cambiarlos = desactivar y crear otra).
revoke all on public.route_stops from anon, authenticated;
grant select on public.route_stops to authenticated;
grant insert (operator_id, route_id, student_id, location, stop_order, notify_radius_m, active)
  on public.route_stops to authenticated;
grant update (location, stop_order, notify_radius_m, active) on public.route_stops to authenticated;

create policy "owner/staff ven paradas de su empresa" on public.route_stops
  for select to authenticated
  using (private.has_role(operator_id, '{owner,staff}'));
create policy "owner/staff crean paradas en su empresa" on public.route_stops
  for insert to authenticated
  with check (private.has_role(operator_id, '{owner,staff}'));
create policy "owner/staff editan paradas de su empresa" on public.route_stops
  for update to authenticated
  using (private.has_role(operator_id, '{owner,staff}'))
  with check (private.has_role(operator_id, '{owner,staff}'));
