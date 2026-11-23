-- ATDE-25-T02: el padre ve solo paradas activas de sus hijos activos en rutas activas (constitución §6).
-- Chofer: sin política hasta trips (ATDE-31); ahí se limita a sus viajes de hoy.
-- security definer: el padre no ve routes por RLS; no lee route_stops (sin recursión).
create function private.is_active_route(route uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.routes r where r.id = route and r.active);
$$;
revoke execute on function private.is_active_route(uuid) from public, anon;
grant execute on function private.is_active_route(uuid) to authenticated;

create policy "padre ve paradas activas de sus hijos" on public.route_stops
  for select to authenticated
  using (active and private.is_guardian_of(student_id) and private.is_active_route(route_id));
