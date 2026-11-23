-- ATDE-25-T01: paradas (route_stops) con FKs por empresa, una activa por niño y ruta, RLS owner/staff.
-- Padre y chofer en route-stops-parent.test.sql. Empresa A: O owner, S staff. Empresa B: X owner.
begin;
create extension if not exists pgtap with schema extensions;
select plan(32);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000025a1', '50625000001'),  -- O
  ('00000000-0000-0000-0000-0000000025a2', '50625000002'),  -- S
  ('00000000-0000-0000-0000-0000000025b1', '50625000003');  -- X
insert into public.operators (id, name, country, currency, timezone) values
  ('00000000-0000-0000-0000-00000025aaaa', 'Busetas A', 'CR', 'CRC', 'America/Costa_Rica'),
  ('00000000-0000-0000-0000-00000025bbbb', 'Busetas B', 'CR', 'CRC', 'America/Costa_Rica');
insert into public.memberships (profile_id, operator_id, role) values
  ('00000000-0000-0000-0000-0000000025a1', '00000000-0000-0000-0000-00000025aaaa', 'owner'),
  ('00000000-0000-0000-0000-0000000025a2', '00000000-0000-0000-0000-00000025aaaa', 'staff'),
  ('00000000-0000-0000-0000-0000000025b1', '00000000-0000-0000-0000-00000025bbbb', 'owner');
insert into public.vehicles (id, operator_id, plate, capacity) values
  ('00000000-0000-0000-0000-0000000251a1', '00000000-0000-0000-0000-00000025aaaa', 'VA', 20),
  ('00000000-0000-0000-0000-0000000251b1', '00000000-0000-0000-0000-00000025bbbb', 'VB', 20);
insert into public.schools (id, operator_id, name, location)
select id::uuid, op::uuid, 'Colegio',
  extensions.st_setsrid(extensions.st_makepoint(-84.09, 9.93), 4326)::extensions.geography
from (values ('00000000-0000-0000-0000-0000000252a1', '00000000-0000-0000-0000-00000025aaaa'),
  ('00000000-0000-0000-0000-0000000252b1', '00000000-0000-0000-0000-00000025bbbb')) as s (id, op);
insert into public.routes (id, operator_id, school_id, vehicle_id, shift) values
  ('00000000-0000-0000-0000-0000000253a1', '00000000-0000-0000-0000-00000025aaaa',
   '00000000-0000-0000-0000-0000000252a1', '00000000-0000-0000-0000-0000000251a1', 'am'),
  ('00000000-0000-0000-0000-0000000253a2', '00000000-0000-0000-0000-00000025aaaa',
   '00000000-0000-0000-0000-0000000252a1', '00000000-0000-0000-0000-0000000251a1', 'pm'),
  ('00000000-0000-0000-0000-0000000253b1', '00000000-0000-0000-0000-00000025bbbb',
   '00000000-0000-0000-0000-0000000252b1', '00000000-0000-0000-0000-0000000251b1', 'am');
insert into public.students (id, operator_id, school_id, full_name)
select id::uuid, op::uuid, school::uuid, 'Niño'
from (values
  ('00000000-0000-0000-0000-0000000254a1', '00000000-0000-0000-0000-00000025aaaa', '00000000-0000-0000-0000-0000000252a1'),
  ('00000000-0000-0000-0000-0000000254a2', '00000000-0000-0000-0000-00000025aaaa', '00000000-0000-0000-0000-0000000252a1'),
  ('00000000-0000-0000-0000-0000000254a3', '00000000-0000-0000-0000-00000025aaaa', '00000000-0000-0000-0000-0000000252a1'),
  ('00000000-0000-0000-0000-0000000254b1', '00000000-0000-0000-0000-00000025bbbb', '00000000-0000-0000-0000-0000000252b1')
) as k (id, op, school);

-- Atajo de prueba: punto en Costa Rica.
create function pg_temp.pt(lon float8) returns extensions.geography language sql as
  $$ select extensions.st_setsrid(extensions.st_makepoint(lon, 9.93), 4326)::extensions.geography $$;

select has_table('public', 'route_stops', 'existe route_stops');
select lives_ok($$insert into public.route_stops (id, operator_id, route_id, student_id, location, stop_order) values
  ('00000000-0000-0000-0000-0000000255a1', '00000000-0000-0000-0000-00000025aaaa',
   '00000000-0000-0000-0000-0000000253a1', '00000000-0000-0000-0000-0000000254a1', pg_temp.pt(-84.10), 1),
  ('00000000-0000-0000-0000-0000000255a2', '00000000-0000-0000-0000-00000025aaaa',
   '00000000-0000-0000-0000-0000000253a2', '00000000-0000-0000-0000-0000000254a1', pg_temp.pt(-84.20), 1),
  ('00000000-0000-0000-0000-0000000255b1', '00000000-0000-0000-0000-00000025bbbb',
   '00000000-0000-0000-0000-0000000253b1', '00000000-0000-0000-0000-0000000254b1', pg_temp.pt(-84.30), 1)$$,
  'un niño con parada AM y otra distinta PM');
select is((select notify_radius_m from public.route_stops where id = '00000000-0000-0000-0000-0000000255a1'),
  500, 'radio de aviso 500 m por defecto');
select ok((select active from public.route_stops where id = '00000000-0000-0000-0000-0000000255a1'), 'activa por defecto');

-- checks y FKs por empresa
select throws_ok($$insert into public.route_stops (operator_id, route_id, student_id, location, stop_order) values
  ('00000000-0000-0000-0000-00000025aaaa', '00000000-0000-0000-0000-0000000253a1',
   '00000000-0000-0000-0000-0000000254a2', pg_temp.pt(-84.1), 0)$$, '23514', null, 'orden 0 rechazado');
select throws_ok($$insert into public.route_stops (operator_id, route_id, student_id, location, stop_order, notify_radius_m)
  values ('00000000-0000-0000-0000-00000025aaaa', '00000000-0000-0000-0000-0000000253a1',
   '00000000-0000-0000-0000-0000000254a2', pg_temp.pt(-84.1), 1, 50)$$, '23514', null, 'radio < 100 m rechazado');
select throws_ok($$insert into public.route_stops (operator_id, route_id, student_id, location, stop_order, notify_radius_m)
  values ('00000000-0000-0000-0000-00000025aaaa', '00000000-0000-0000-0000-0000000253a1',
   '00000000-0000-0000-0000-0000000254a2', pg_temp.pt(-84.1), 1, 5000)$$, '23514', null, 'radio > 2000 m rechazado');
select throws_ok($$insert into public.route_stops (operator_id, route_id, student_id, location, stop_order) values
  ('00000000-0000-0000-0000-00000025aaaa', '00000000-0000-0000-0000-0000000253a1',
   '00000000-0000-0000-0000-0000000254a2', null, 1)$$, '23502', null, 'parada sin ubicación rechazada');
select throws_ok($$insert into public.route_stops (operator_id, route_id, student_id, location, stop_order) values
  ('00000000-0000-0000-0000-00000025aaaa', '00000000-0000-0000-0000-0000000253b1',
   '00000000-0000-0000-0000-0000000254a2', pg_temp.pt(-84.1), 1)$$, '23503', null, 'ruta de otra empresa rechazada');
select throws_ok($$insert into public.route_stops (operator_id, route_id, student_id, location, stop_order) values
  ('00000000-0000-0000-0000-00000025aaaa', '00000000-0000-0000-0000-0000000253a1',
   '00000000-0000-0000-0000-0000000254b1', pg_temp.pt(-84.1), 1)$$, '23503', null, 'estudiante de otra empresa rechazado');
select throws_ok($$insert into public.route_stops (operator_id, route_id, student_id, location, stop_order) values
  ('00000000-0000-0000-0000-00000025aaaa', '00000000-0000-0000-0000-0000000253a1',
   '00000000-0000-0000-0000-0000000254a1', pg_temp.pt(-84.1), 2)$$, '23505', null, 'segunda parada activa en la misma ruta rechazada');

-- historial: desactivar y crear otra en la misma ruta
update public.route_stops set active = false where id = '00000000-0000-0000-0000-0000000255a1';
select lives_ok($$insert into public.route_stops (operator_id, route_id, student_id, location, stop_order) values
  ('00000000-0000-0000-0000-00000025aaaa', '00000000-0000-0000-0000-0000000253a1',
   '00000000-0000-0000-0000-0000000254a1', pg_temp.pt(-84.15), 1)$$, 'nueva parada tras desactivar la anterior');
select is((select count(*) from public.route_stops where student_id = '00000000-0000-0000-0000-0000000254a1'
  and route_id = '00000000-0000-0000-0000-0000000253a1'), 2::bigint, 'la parada desactivada queda como historial');
select has_trigger('public', 'route_stops', 'route_stops_set_updated_at', 'updated_at se mantiene por trigger');

set local role anon;
select throws_ok('select 1 from public.route_stops', '42501', null, 'anon no ve paradas');
reset role;

-- O: owner de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000025a1","role":"authenticated"}';
select is((select count(*) from public.route_stops), 3::bigint, 'owner ve solo paradas de su empresa');
select lives_ok($$insert into public.route_stops (operator_id, route_id, student_id, location, stop_order) values
  ('00000000-0000-0000-0000-00000025aaaa', '00000000-0000-0000-0000-0000000253a1',
   '00000000-0000-0000-0000-0000000254a2', pg_temp.pt(-84.12), 2)$$, 'owner crea parada en su empresa');
select throws_ok($$insert into public.route_stops (operator_id, route_id, student_id, location, stop_order) values
  ('00000000-0000-0000-0000-00000025bbbb', '00000000-0000-0000-0000-0000000253b1',
   '00000000-0000-0000-0000-0000000254b1', pg_temp.pt(-84.1), 2)$$, '42501', null, 'owner no crea parada en otra empresa');
select lives_ok($$update public.route_stops set stop_order = 3, notify_radius_m = 800, location = pg_temp.pt(-84.11)
  where id = '00000000-0000-0000-0000-0000000255a2'$$, 'owner edita orden, radio y ubicación');
select throws_ok($$update public.route_stops set route_id = '00000000-0000-0000-0000-0000000253a1'$$,
  '42501', null, 'nadie cambia la ruta de una parada');
select throws_ok($$update public.route_stops set student_id = '00000000-0000-0000-0000-0000000254a3'$$,
  '42501', null, 'nadie cambia el estudiante de una parada');
select throws_ok($$update public.route_stops set operator_id = '00000000-0000-0000-0000-00000025bbbb'$$,
  '42501', null, 'owner no mueve paradas a otra empresa');
select throws_ok('delete from public.route_stops', '42501', null, 'nadie borra paradas');
reset role;

-- S: staff de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000025a2","role":"authenticated"}';
select is((select count(*) from public.route_stops), 4::bigint, 'staff ve paradas de su empresa');
select lives_ok($$insert into public.route_stops (operator_id, route_id, student_id, location, stop_order) values
  ('00000000-0000-0000-0000-00000025aaaa', '00000000-0000-0000-0000-0000000253a2',
   '00000000-0000-0000-0000-0000000254a3', pg_temp.pt(-84.13), 2)$$, 'staff crea parada');
select lives_ok($$update public.route_stops set active = false
  where id = '00000000-0000-0000-0000-0000000255a2'$$, 'staff desactiva parada');
select throws_ok('delete from public.route_stops', '42501', null, 'staff no borra paradas');
reset role;

-- X: owner de B
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000025b1","role":"authenticated"}';
select is_empty($$select 1 from public.route_stops
  where operator_id = '00000000-0000-0000-0000-00000025aaaa'$$, 'X no ve paradas de A');
update public.route_stops set stop_order = 99;
reset role;

-- resultados de escrituras
select is((select stop_order from public.route_stops where id = '00000000-0000-0000-0000-0000000255a2'), 3,
  'edición del owner persistida');
select is((select active from public.route_stops where id = '00000000-0000-0000-0000-0000000255a2'), false,
  'desactivación de staff persistida');
select is_empty($$select 1 from public.route_stops where stop_order = 99
  and operator_id = '00000000-0000-0000-0000-00000025aaaa'$$, 'X no edita paradas de A');
select is((select stop_order from public.route_stops where id = '00000000-0000-0000-0000-0000000255b1'), 99,
  'X edita paradas de su empresa');

select * from finish();
rollback;
