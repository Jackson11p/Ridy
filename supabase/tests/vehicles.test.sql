-- ATDE-9-T01: PostGIS, busetas (vehicles), chofer habitual válido y RLS por rol.
-- Empresa A: O owner, S staff, D y D2 drivers, Z staff (no driver), DI driver inactivo. Empresa B: X owner.
begin;
create extension if not exists pgtap with schema extensions;
select plan(35);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000009a1', '50630000001'),  -- O
  ('00000000-0000-0000-0000-0000000009a2', '50630000002'),  -- S
  ('00000000-0000-0000-0000-0000000009a3', '50630000003'),  -- D
  ('00000000-0000-0000-0000-0000000009a4', '50630000004'),  -- D2
  ('00000000-0000-0000-0000-0000000009a5', '50630000005'),  -- Z
  ('00000000-0000-0000-0000-0000000009a6', '50630000006'),  -- DI
  ('00000000-0000-0000-0000-0000000009b1', '50630000007');  -- X
insert into public.operators (id, name, country, currency, timezone) values
  ('00000000-0000-0000-0000-00000009aaaa', 'Busetas A', 'CR', 'CRC', 'America/Costa_Rica'),
  ('00000000-0000-0000-0000-00000009bbbb', 'Busetas B', 'CR', 'CRC', 'America/Costa_Rica');
insert into public.memberships (profile_id, operator_id, role, active) values
  ('00000000-0000-0000-0000-0000000009a1', '00000000-0000-0000-0000-00000009aaaa', 'owner', true),
  ('00000000-0000-0000-0000-0000000009a2', '00000000-0000-0000-0000-00000009aaaa', 'staff', true),
  ('00000000-0000-0000-0000-0000000009a3', '00000000-0000-0000-0000-00000009aaaa', 'driver', true),
  ('00000000-0000-0000-0000-0000000009a4', '00000000-0000-0000-0000-00000009aaaa', 'driver', true),
  ('00000000-0000-0000-0000-0000000009a5', '00000000-0000-0000-0000-00000009aaaa', 'staff', true),
  ('00000000-0000-0000-0000-0000000009a6', '00000000-0000-0000-0000-00000009aaaa', 'driver', false),
  ('00000000-0000-0000-0000-0000000009b1', '00000000-0000-0000-0000-00000009bbbb', 'owner', true);
insert into public.vehicles (id, operator_id, plate, capacity, default_driver_id, active) values
  ('00000000-0000-0000-0000-0000000091a1', '00000000-0000-0000-0000-00000009aaaa', 'AAA111', 20,
   '00000000-0000-0000-0000-0000000009a3', true),
  ('00000000-0000-0000-0000-0000000091a2', '00000000-0000-0000-0000-00000009aaaa', 'AAA222', 20,
   '00000000-0000-0000-0000-0000000009a4', true),
  ('00000000-0000-0000-0000-0000000091a3', '00000000-0000-0000-0000-00000009aaaa', 'AAA333', 20,
   '00000000-0000-0000-0000-0000000009a3', false),
  ('00000000-0000-0000-0000-0000000091b1', '00000000-0000-0000-0000-00000009bbbb', 'BBB111', 30, null, true);

select has_extension('extensions', 'postgis', 'PostGIS activado');
-- checks
select throws_ok($$insert into public.vehicles (operator_id, plate, capacity)
  values ('00000000-0000-0000-0000-00000009aaaa', 'C0', 0)$$, '23514', null, 'capacidad 0 rechazada');
select throws_ok($$insert into public.vehicles (operator_id, plate, capacity)
  values ('00000000-0000-0000-0000-00000009aaaa', 'C61', 61)$$, '23514', null, 'capacidad 61 rechazada');
select throws_ok($$insert into public.vehicles (operator_id, plate, capacity)
  values ('00000000-0000-0000-0000-00000009aaaa', '  ', 10)$$, '23514', null, 'placa vacía rechazada');
select throws_ok($$insert into public.vehicles (operator_id, plate, capacity)
  values ('00000000-0000-0000-0000-00000009aaaa', 'AAA111', 10)$$, '23505', null, 'placa duplicada en la empresa');
select lives_ok($$insert into public.vehicles (operator_id, plate, capacity)
  values ('00000000-0000-0000-0000-00000009bbbb', 'AAA111', 10)$$, 'misma placa en otra empresa se permite');
select is((select active from public.vehicles where plate = 'AAA111'
  and operator_id = '00000000-0000-0000-0000-00000009bbbb'), true, 'buseta activa por defecto');

-- chofer habitual válido
select throws_ok($$insert into public.vehicles (operator_id, plate, capacity, default_driver_id)
  values ('00000000-0000-0000-0000-00000009aaaa', 'Z1', 10, '00000000-0000-0000-0000-0000000009a5')$$,
  '23514', null, 'chofer habitual sin rol driver rechazado');
select throws_ok($$insert into public.vehicles (operator_id, plate, capacity, default_driver_id)
  values ('00000000-0000-0000-0000-00000009aaaa', 'DI1', 10, '00000000-0000-0000-0000-0000000009a6')$$,
  '23514', null, 'chofer habitual con membership inactiva rechazado');
select throws_ok($$insert into public.vehicles (operator_id, plate, capacity, default_driver_id)
  values ('00000000-0000-0000-0000-00000009bbbb', 'B2', 10, '00000000-0000-0000-0000-0000000009a3')$$,
  '23514', null, 'chofer habitual de otra empresa rechazado');
select throws_ok($$update public.vehicles set default_driver_id = '00000000-0000-0000-0000-0000000009a5'
  where plate = 'AAA222'$$, '23514', null, 'update a chofer habitual inválido rechazado');

-- anon
set local role anon;
select throws_ok('select 1 from public.vehicles', '42501', null, 'anon no ve busetas');
reset role;

-- O: owner de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000009a1","role":"authenticated"}';
select is((select count(*) from public.vehicles), 3::bigint, 'owner ve las busetas de su empresa (activas e inactivas)');
select lives_ok($$insert into public.vehicles (operator_id, plate, capacity, default_driver_id)
  values ('00000000-0000-0000-0000-00000009aaaa', 'AAA444', 15, '00000000-0000-0000-0000-0000000009a4')$$,
  'owner crea buseta en su empresa');
select throws_ok($$insert into public.vehicles (operator_id, plate, capacity)
  values ('00000000-0000-0000-0000-00000009bbbb', 'BBB999', 15)$$, '42501', null, 'owner no crea buseta en otra empresa');
select lives_ok($$update public.vehicles set capacity = 25 where plate = 'AAA111'$$, 'owner edita buseta de su empresa');
update public.vehicles set capacity = 1 where id = '00000000-0000-0000-0000-0000000091b1';
select throws_ok($$update public.vehicles set operator_id = '00000000-0000-0000-0000-00000009bbbb'$$,
  '42501', null, 'owner no mueve busetas a otra empresa');
select throws_ok('delete from public.vehicles', '42501', null, 'nadie borra busetas');
reset role;

-- S: staff de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000009a2","role":"authenticated"}';
select is((select count(*) from public.vehicles), 4::bigint, 'staff ve las busetas de su empresa');
select lives_ok($$insert into public.vehicles (operator_id, plate, capacity)
  values ('00000000-0000-0000-0000-00000009aaaa', 'AAA555', 12)$$, 'staff crea buseta en su empresa');
select lives_ok($$update public.vehicles set active = false where plate = 'AAA555'$$, 'staff desactiva buseta');
select throws_ok('delete from public.vehicles', '42501', null, 'staff no borra busetas');
reset role;

-- X: owner de B
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000009b1","role":"authenticated"}';
select is_empty($$select 1 from public.vehicles
  where operator_id = '00000000-0000-0000-0000-00000009aaaa'$$, 'X no ve busetas de A');
update public.vehicles set capacity = 2 where plate = 'AAA111';
reset role;

-- D: driver de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000009a3","role":"authenticated"}';
select results_eq('select plate from public.vehicles', $$values ('AAA111')$$,
  'driver ve solo su buseta activa');
select throws_ok($$insert into public.vehicles (operator_id, plate, capacity)
  values ('00000000-0000-0000-0000-00000009aaaa', 'DDD1', 10)$$, '42501', null, 'driver no crea busetas');
update public.vehicles set capacity = 3 where plate = 'AAA111';
select throws_ok('delete from public.vehicles', '42501', null, 'driver no borra busetas');
reset role;

-- DI: driver con membership inactiva
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000009a6","role":"authenticated"}';
select is((select count(*) from public.vehicles), 0::bigint, 'driver inactivo no ve busetas');
reset role;

-- resultados de escrituras
select is((select capacity from public.vehicles where id = '00000000-0000-0000-0000-0000000091a1'), 25,
  'edición del owner persistida; X y driver no editan');
select is((select capacity from public.vehicles where id = '00000000-0000-0000-0000-0000000091b1'), 30,
  'owner de A no edita buseta de B');
select is((select active from public.vehicles where plate = 'AAA555'), false, 'desactivación de staff persistida');

-- chofer desactivado deja de ver su buseta; la buseta sigue editable
update public.memberships set active = false where profile_id = '00000000-0000-0000-0000-0000000009a3';
select lives_ok($$update public.vehicles set capacity = 26 where id = '00000000-0000-0000-0000-0000000091a1'$$,
  'buseta con chofer ya inactivo sigue editable sin cambiar chofer');
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000009a3","role":"authenticated"}';
select is((select count(*) from public.vehicles), 0::bigint, 'driver desactivado no ve su buseta');
reset role;

-- perfil inactivo pierde acceso
update public.profiles set active = false where id = '00000000-0000-0000-0000-0000000009a4';
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000009a4","role":"authenticated"}';
select is((select count(*) from public.vehicles), 0::bigint, 'driver con perfil inactivo no ve busetas');
reset role;

select has_trigger('public', 'vehicles', 'vehicles_set_updated_at', 'updated_at se mantiene por trigger');
select col_type_is('public', 'vehicles', 'updated_at', 'timestamp with time zone', 'fechas en timestamptz');

select * from finish();
rollback;
