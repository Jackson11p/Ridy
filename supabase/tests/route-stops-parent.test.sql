-- ATDE-25-T02: el padre ve solo paradas activas de sus hijos activos en rutas activas; el chofer aún ninguna.
-- Empresa A. P1 encargado de K1, K3 (inactivo) y K4 (vínculo inactivo); P2 de K2. D chofer habitual de la buseta.
begin;
create extension if not exists pgtap with schema extensions;
select plan(12);

insert into auth.users (id, phone)
select ('00000000-0000-0000-0000-0000000026a' || n)::uuid, '5062600000' || n
from generate_series(1, 3) as n;  -- a1 P1, a2 P2, a3 D
insert into public.operators (id, name, country, currency, timezone) values
  ('00000000-0000-0000-0000-00000026aaaa', 'Busetas A', 'CR', 'CRC', 'America/Costa_Rica');
insert into public.memberships (profile_id, operator_id, role) values
  ('00000000-0000-0000-0000-0000000026a3', '00000000-0000-0000-0000-00000026aaaa', 'driver');
insert into public.vehicles (id, operator_id, plate, capacity, default_driver_id) values
  ('00000000-0000-0000-0000-0000000261a1', '00000000-0000-0000-0000-00000026aaaa', 'VA', 20,
   '00000000-0000-0000-0000-0000000026a3');
insert into public.schools (id, operator_id, name, location) values
  ('00000000-0000-0000-0000-0000000262a1', '00000000-0000-0000-0000-00000026aaaa', 'Colegio',
   extensions.st_setsrid(extensions.st_makepoint(-84.09, 9.93), 4326)::extensions.geography);
insert into public.routes (id, operator_id, school_id, vehicle_id, shift, active)
select ('00000000-0000-0000-0000-0000000263a' || n)::uuid, '00000000-0000-0000-0000-00000026aaaa',
  '00000000-0000-0000-0000-0000000262a1', '00000000-0000-0000-0000-0000000261a1', s::public.route_shift, a
from (values (1, 'am', true), (2, 'pm', true), (3, 'am', false)) as r (n, s, a);  -- a3 ruta inactiva
insert into public.students (id, operator_id, school_id, full_name, active)
select ('00000000-0000-0000-0000-0000000264a' || n)::uuid, '00000000-0000-0000-0000-00000026aaaa',
  '00000000-0000-0000-0000-0000000262a1', 'K' || n, n <> 3
from generate_series(1, 4) as n;
insert into public.guardians (operator_id, student_id, profile_id, relationship, active)
select '00000000-0000-0000-0000-00000026aaaa', ('00000000-0000-0000-0000-0000000264a' || k)::uuid,
  ('00000000-0000-0000-0000-0000000026a' || p)::uuid, 'mother', a
from (values (1, 1, true), (3, 1, true), (4, 1, false), (2, 2, true)) as g (k, p, a);
-- s1/s2 K1 AM y PM; s3 K1 vieja inactiva; s4 K1 en ruta inactiva; s5 K2; s6 K3 inactivo; s7 K4 sin vínculo activo.
insert into public.route_stops (id, operator_id, route_id, student_id, location, stop_order, active)
select ('00000000-0000-0000-0000-0000000265a' || n)::uuid, '00000000-0000-0000-0000-00000026aaaa',
  ('00000000-0000-0000-0000-0000000263a' || r)::uuid, ('00000000-0000-0000-0000-0000000264a' || k)::uuid,
  extensions.st_setsrid(extensions.st_makepoint(-84 - n / 100.0, 9.93), 4326)::extensions.geography, n, a
from (values (1, 1, 1, true), (2, 2, 1, true), (3, 1, 1, false), (4, 3, 1, true),
  (5, 1, 2, true), (6, 1, 3, true), (7, 1, 4, true)) as s (n, r, k, a);

-- P1
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000026a1","role":"authenticated"}';
select results_eq('select id from public.route_stops order by id',
  $$values ('00000000-0000-0000-0000-0000000265a1'::uuid), ('00000000-0000-0000-0000-0000000265a2'::uuid)$$,
  'padre ve las paradas AM y PM de su hijo');
select is_empty($$select 1 from public.route_stops where student_id = '00000000-0000-0000-0000-0000000264a2'$$,
  'padre nunca ve la dirección de otro niño');
select is_empty($$select 1 from public.route_stops where id = '00000000-0000-0000-0000-0000000265a3'$$,
  'padre no ve paradas desactivadas');
select is_empty($$select 1 from public.route_stops where id = '00000000-0000-0000-0000-0000000265a4'$$,
  'padre no ve paradas de rutas inactivas');
select is_empty($$select 1 from public.route_stops where id = '00000000-0000-0000-0000-0000000265a6'$$,
  'padre no ve paradas de un hijo inactivo');
select is_empty($$select 1 from public.route_stops where id = '00000000-0000-0000-0000-0000000265a7'$$,
  'padre no ve paradas sin vínculo activo');
select throws_ok($$insert into public.route_stops (operator_id, route_id, student_id, location, stop_order) values
  ('00000000-0000-0000-0000-00000026aaaa', '00000000-0000-0000-0000-0000000263a2',
   '00000000-0000-0000-0000-0000000264a2', extensions.st_setsrid(extensions.st_makepoint(-84.1, 9.93), 4326)::extensions.geography, 9)$$,
  '42501', null, 'padre no crea paradas');
update public.route_stops set stop_order = 99;
select throws_ok('delete from public.route_stops', '42501', null, 'padre no borra paradas');
reset role;

-- P2
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000026a2","role":"authenticated"}';
select results_eq('select id from public.route_stops',
  $$values ('00000000-0000-0000-0000-0000000265a5'::uuid)$$, 'otra familia ve solo la parada de su hijo');
reset role;

-- D: chofer habitual, sin viajes (trips llega en ATDE-31)
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000026a3","role":"authenticated"}';
select is_empty('select 1 from public.route_stops', 'chofer sin viaje hoy no ve paradas');
select is_empty('select 1 from public.students', 'chofer sin viaje hoy no ve estudiantes');
reset role;

select is_empty('select 1 from public.route_stops where stop_order = 99', 'padre no edita paradas');

select * from finish();
rollback;
