-- ATDE-9-T03/T05: el chofer solo lee rutas activas de su buseta y sus colegios activos; no escribe.
-- Empresa A: D driver (V1), D2 driver sin buseta, DI driver inactivo (V2), M driver (V4).
-- Empresa B: M owner. D ve R1 y R3; R2 inactiva, R4 de V2, R5 de V3 (inactiva).
begin;
create extension if not exists pgtap with schema extensions;
select plan(18);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000006a3', '50610000013'),  -- D
  ('00000000-0000-0000-0000-0000000006a4', '50610000014'),  -- D2
  ('00000000-0000-0000-0000-0000000006a5', '50610000015'),  -- DI
  ('00000000-0000-0000-0000-0000000006a6', '50610000016');  -- M
insert into public.operators (id, name, country, currency, timezone) values
  ('00000000-0000-0000-0000-00000006aaaa', 'Busetas A', 'CR', 'CRC', 'America/Costa_Rica'),
  ('00000000-0000-0000-0000-00000006bbbb', 'Busetas B', 'CR', 'CRC', 'America/Costa_Rica');
insert into public.memberships (profile_id, operator_id, role) values
  ('00000000-0000-0000-0000-0000000006a3', '00000000-0000-0000-0000-00000006aaaa', 'driver'),
  ('00000000-0000-0000-0000-0000000006a4', '00000000-0000-0000-0000-00000006aaaa', 'driver'),
  ('00000000-0000-0000-0000-0000000006a5', '00000000-0000-0000-0000-00000006aaaa', 'driver'),
  ('00000000-0000-0000-0000-0000000006a6', '00000000-0000-0000-0000-00000006aaaa', 'driver'),
  ('00000000-0000-0000-0000-0000000006a6', '00000000-0000-0000-0000-00000006bbbb', 'owner');
insert into public.vehicles (id, operator_id, plate, capacity, default_driver_id, active)
select id::uuid, op::uuid, plate, 20, driver::uuid, active
from (values
  ('00000000-0000-0000-0000-0000000061a1', '00000000-0000-0000-0000-00000006aaaa', 'V1',
   '00000000-0000-0000-0000-0000000006a3', true),
  ('00000000-0000-0000-0000-0000000061a2', '00000000-0000-0000-0000-00000006aaaa', 'V2',
   '00000000-0000-0000-0000-0000000006a5', true),
  ('00000000-0000-0000-0000-0000000061a3', '00000000-0000-0000-0000-00000006aaaa', 'V3',
   '00000000-0000-0000-0000-0000000006a3', false),
  ('00000000-0000-0000-0000-0000000061a4', '00000000-0000-0000-0000-00000006aaaa', 'V4',
   '00000000-0000-0000-0000-0000000006a6', true),
  ('00000000-0000-0000-0000-0000000061b1', '00000000-0000-0000-0000-00000006bbbb', 'VB', null, true)
) as v (id, op, plate, driver, active);
update public.memberships set active = false where profile_id = '00000000-0000-0000-0000-0000000006a5';
insert into public.schools (id, operator_id, name, location, active)
select id::uuid, op::uuid, name,
  extensions.st_setsrid(extensions.st_makepoint(-84.09, 9.93), 4326)::extensions.geography, active
from (values
  ('00000000-0000-0000-0000-0000000062a1', '00000000-0000-0000-0000-00000006aaaa', 'S1', true),
  ('00000000-0000-0000-0000-0000000062a2', '00000000-0000-0000-0000-00000006aaaa', 'S2', true),
  ('00000000-0000-0000-0000-0000000062a3', '00000000-0000-0000-0000-00000006aaaa', 'S3', false),
  ('00000000-0000-0000-0000-0000000062a4', '00000000-0000-0000-0000-00000006aaaa', 'S4', true),
  ('00000000-0000-0000-0000-0000000062a5', '00000000-0000-0000-0000-00000006aaaa', 'S5', true),
  ('00000000-0000-0000-0000-0000000062b1', '00000000-0000-0000-0000-00000006bbbb', 'SB', true)
) as s (id, op, name, active);
insert into public.routes (id, operator_id, school_id, vehicle_id, shift, active)
select ('00000000-0000-0000-0000-0000000063' || id)::uuid, op::uuid,
  ('00000000-0000-0000-0000-0000000062' || school)::uuid,
  ('00000000-0000-0000-0000-0000000061' || vehicle)::uuid, shift::public.route_shift, active
from (values
  ('a1', '00000000-0000-0000-0000-00000006aaaa', 'a1', 'a1', 'am', true),
  ('a2', '00000000-0000-0000-0000-00000006aaaa', 'a2', 'a1', 'pm', false),
  ('a3', '00000000-0000-0000-0000-00000006aaaa', 'a3', 'a1', 'am', true),
  ('a4', '00000000-0000-0000-0000-00000006aaaa', 'a4', 'a2', 'am', true),
  ('a5', '00000000-0000-0000-0000-00000006aaaa', 'a1', 'a3', 'pm', true),
  ('a6', '00000000-0000-0000-0000-00000006aaaa', 'a5', 'a4', 'am', true),
  ('b1', '00000000-0000-0000-0000-00000006bbbb', 'b1', 'b1', 'am', true)
) as r (id, op, school, vehicle, shift, active);

-- D: driver de A con buseta V1
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000006a3","role":"authenticated"}';
select set_eq('select id from public.routes', $$values
  ('00000000-0000-0000-0000-0000000063a1'::uuid), ('00000000-0000-0000-0000-0000000063a3'::uuid)$$,
  'driver ve solo rutas activas de su buseta activa');
select results_eq('select name from public.schools', $$values ('S1')$$,
  'driver ve solo colegios activos de sus rutas activas');
select throws_ok($$insert into public.routes (operator_id, school_id, vehicle_id, shift) values
  ('00000000-0000-0000-0000-00000006aaaa', '00000000-0000-0000-0000-0000000062a1',
   '00000000-0000-0000-0000-0000000061a1', 'am')$$, '42501', null, 'driver no crea rutas');
update public.routes set shift = 'pm' where id = '00000000-0000-0000-0000-0000000063a3';
update public.schools set name = 'por driver' where id = '00000000-0000-0000-0000-0000000062a1';
select throws_ok('delete from public.routes', '42501', null, 'driver no borra rutas');
select throws_ok('delete from public.schools', '42501', null, 'driver no borra colegios');
reset role;

-- D2: driver sin buseta; DI: driver inactivo con buseta
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000006a4","role":"authenticated"}';
select is((select count(*) from public.routes), 0::bigint, 'driver sin buseta no ve rutas');
select is((select count(*) from public.schools), 0::bigint, 'driver sin buseta no ve colegios');
reset role;
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000006a5","role":"authenticated"}';
select is((select count(*) from public.routes), 0::bigint, 'driver inactivo no ve rutas');
select is((select count(*) from public.schools), 0::bigint, 'driver inactivo no ve colegios');
reset role;

-- M: owner de B y driver de A: en A solo lo de su buseta
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000006a6","role":"authenticated"}';
select set_eq('select id from public.routes', $$values
  ('00000000-0000-0000-0000-0000000063a6'::uuid), ('00000000-0000-0000-0000-0000000063b1'::uuid)$$,
  'owner de B y driver de A: rutas de B y solo la de su buseta en A');
select set_eq('select name from public.schools', $$values ('S5'), ('SB')$$,
  'owner de B y driver de A: colegios de B y solo el de su ruta en A');
select set_eq('select plate from public.vehicles', $$values ('V4'), ('VB')$$,
  'owner de B y driver de A: busetas de B y solo la suya en A');
update public.routes set shift = 'pm' where id = '00000000-0000-0000-0000-0000000063a6';
reset role;

-- resultados de escrituras
select is((select shift::text from public.routes where id = '00000000-0000-0000-0000-0000000063a3'), 'am',
  'driver no edita rutas');
select is((select name from public.schools where id = '00000000-0000-0000-0000-0000000062a1'), 'S1',
  'driver no edita colegios');
select is((select shift::text from public.routes where id = '00000000-0000-0000-0000-0000000063a6'), 'am',
  'owner de B no edita como driver rutas de A');

-- buseta desactivada: el chofer pierde rutas y colegios
update public.vehicles set active = false where id = '00000000-0000-0000-0000-0000000061a1';
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000006a3","role":"authenticated"}';
select is((select count(*) from public.routes), 0::bigint, 'buseta inactiva: driver no ve rutas');
select is((select count(*) from public.schools), 0::bigint, 'buseta inactiva: driver no ve colegios');
select is((select count(*) from public.vehicles), 0::bigint, 'buseta inactiva: driver no la ve');
reset role;

select * from finish();
rollback;
