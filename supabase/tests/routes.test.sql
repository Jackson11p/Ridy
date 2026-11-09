-- ATDE-9-T03/T05: rutas (routes), código RDY- generado, FKs por empresa y RLS owner/staff.
-- Visibilidad del chofer en routes-driver.test.sql. Empresa A: O owner, S staff. Empresa B: X owner.
begin;
create extension if not exists pgtap with schema extensions;
select plan(30);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000007a1', '50610000001'),  -- O
  ('00000000-0000-0000-0000-0000000007a2', '50610000002'),  -- S
  ('00000000-0000-0000-0000-0000000007b1', '50610000003');  -- X
insert into public.operators (id, name, country, currency, timezone) values
  ('00000000-0000-0000-0000-00000007aaaa', 'Busetas A', 'CR', 'CRC', 'America/Costa_Rica'),
  ('00000000-0000-0000-0000-00000007bbbb', 'Busetas B', 'CR', 'CRC', 'America/Costa_Rica');
insert into public.memberships (profile_id, operator_id, role) values
  ('00000000-0000-0000-0000-0000000007a1', '00000000-0000-0000-0000-00000007aaaa', 'owner'),
  ('00000000-0000-0000-0000-0000000007a2', '00000000-0000-0000-0000-00000007aaaa', 'staff'),
  ('00000000-0000-0000-0000-0000000007b1', '00000000-0000-0000-0000-00000007bbbb', 'owner');
insert into public.vehicles (id, operator_id, plate, capacity) values
  ('00000000-0000-0000-0000-0000000071a1', '00000000-0000-0000-0000-00000007aaaa', 'V1', 20),
  ('00000000-0000-0000-0000-0000000071a2', '00000000-0000-0000-0000-00000007aaaa', 'V2', 20),
  ('00000000-0000-0000-0000-0000000071b1', '00000000-0000-0000-0000-00000007bbbb', 'VB', 20);
insert into public.schools (id, operator_id, name, location)
select id::uuid, op::uuid, name,
  extensions.st_setsrid(extensions.st_makepoint(-84.09, 9.93), 4326)::extensions.geography
from (values
  ('00000000-0000-0000-0000-0000000072a1', '00000000-0000-0000-0000-00000007aaaa', 'S1'),
  ('00000000-0000-0000-0000-0000000072a2', '00000000-0000-0000-0000-00000007aaaa', 'S2'),
  ('00000000-0000-0000-0000-0000000072b1', '00000000-0000-0000-0000-00000007bbbb', 'SB')
) as s (id, op, name);
insert into public.routes (id, operator_id, school_id, vehicle_id, shift) values
  ('00000000-0000-0000-0000-0000000073a1', '00000000-0000-0000-0000-00000007aaaa',
   '00000000-0000-0000-0000-0000000072a1', '00000000-0000-0000-0000-0000000071a1', 'am'),
  ('00000000-0000-0000-0000-0000000073a2', '00000000-0000-0000-0000-00000007aaaa',
   '00000000-0000-0000-0000-0000000072a2', '00000000-0000-0000-0000-0000000071a2', 'pm'),
  ('00000000-0000-0000-0000-0000000073b1', '00000000-0000-0000-0000-00000007bbbb',
   '00000000-0000-0000-0000-0000000072b1', '00000000-0000-0000-0000-0000000071b1', 'am');

select enum_has_labels('public', 'route_shift', array['am', 'pm'], 'turno am/pm');
select throws_ok($$insert into public.routes (operator_id, school_id, vehicle_id, shift) values
  ('00000000-0000-0000-0000-00000007aaaa', '00000000-0000-0000-0000-0000000072a1',
   '00000000-0000-0000-0000-0000000071a1', 'noche')$$, '22P02', null, 'turno inválido rechazado');

-- código de ruta
select ok((select bool_and(code ~ '^RDY-[A-Z0-9]{6}$') from public.routes), 'código generado con formato RDY-XXXXXX');
select is((select count(distinct code) from public.routes), (select count(*) from public.routes), 'códigos únicos');
select ok((select bool_and(private.generate_route_code() ~ '^RDY-[2-9A-HJ-NP-Z]{6}$')
  from generate_series(1, 500)), 'código sin caracteres ambiguos (0, O, 1, I)');
select throws_ok($$insert into public.routes (operator_id, school_id, vehicle_id, shift, code) values
  ('00000000-0000-0000-0000-00000007aaaa', '00000000-0000-0000-0000-0000000072a1',
   '00000000-0000-0000-0000-0000000071a1', 'am',
   (select code from public.routes where id = '00000000-0000-0000-0000-0000000073a1'))$$,
  '23505', null, 'código duplicado rechazado');
select throws_ok($$insert into public.routes (operator_id, school_id, vehicle_id, shift, code) values
  ('00000000-0000-0000-0000-00000007aaaa', '00000000-0000-0000-0000-0000000072a1',
   '00000000-0000-0000-0000-0000000071a1', 'am', 'RDY-abc')$$, '23514', null, 'código con formato inválido rechazado');

-- FKs compuestas: colegio y buseta de la misma empresa
select throws_ok($$insert into public.routes (operator_id, school_id, vehicle_id, shift) values
  ('00000000-0000-0000-0000-00000007aaaa', '00000000-0000-0000-0000-0000000072b1',
   '00000000-0000-0000-0000-0000000071a1', 'am')$$, '23503', null, 'ruta con colegio de otra empresa rechazada');
select throws_ok($$insert into public.routes (operator_id, school_id, vehicle_id, shift) values
  ('00000000-0000-0000-0000-00000007aaaa', '00000000-0000-0000-0000-0000000072a1',
   '00000000-0000-0000-0000-0000000071b1', 'am')$$, '23503', null, 'ruta con buseta de otra empresa rechazada');

-- anon
set local role anon;
select throws_ok('select 1 from public.routes', '42501', null, 'anon no ve rutas');
reset role;

-- O: owner de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000007a1","role":"authenticated"}';
select is((select count(*) from public.routes), 2::bigint, 'owner ve solo rutas de su empresa');
select lives_ok($$insert into public.routes (operator_id, school_id, vehicle_id, shift) values
  ('00000000-0000-0000-0000-00000007aaaa', '00000000-0000-0000-0000-0000000072a2',
   '00000000-0000-0000-0000-0000000071a1', 'pm')$$, 'owner crea ruta en su empresa con código generado');
select throws_ok($$insert into public.routes (operator_id, school_id, vehicle_id, shift, code) values
  ('00000000-0000-0000-0000-00000007aaaa', '00000000-0000-0000-0000-0000000072a2',
   '00000000-0000-0000-0000-0000000071a1', 'am', 'RDY-ABCDEF')$$, '42501', null, 'cliente no elige el código');
select throws_ok($$insert into public.routes (operator_id, school_id, vehicle_id, shift) values
  ('00000000-0000-0000-0000-00000007bbbb', '00000000-0000-0000-0000-0000000072b1',
   '00000000-0000-0000-0000-0000000071b1', 'pm')$$, '42501', null, 'owner no crea ruta en otra empresa');
select lives_ok($$update public.routes set shift = 'pm'
  where id = '00000000-0000-0000-0000-0000000073a1'$$, 'owner edita ruta de su empresa');
select throws_ok($$update public.routes set school_id = '00000000-0000-0000-0000-0000000072b1'
  where id = '00000000-0000-0000-0000-0000000073a1'$$, '23503', null, 'owner no apunta ruta a colegio de otra empresa');
select throws_ok($$update public.routes set vehicle_id = '00000000-0000-0000-0000-0000000071b1'
  where id = '00000000-0000-0000-0000-0000000073a1'$$, '23503', null, 'owner no apunta ruta a buseta de otra empresa');
update public.routes set shift = 'pm' where id = '00000000-0000-0000-0000-0000000073b1';
select throws_ok($$update public.routes set code = 'RDY-ABCDEF'$$, '42501', null, 'nadie edita el código de ruta');
select throws_ok($$update public.routes set operator_id = '00000000-0000-0000-0000-00000007bbbb'$$,
  '42501', null, 'owner no mueve rutas a otra empresa');
select throws_ok('delete from public.routes', '42501', null, 'nadie borra rutas');
reset role;

-- S: staff de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000007a2","role":"authenticated"}';
select is((select count(*) from public.routes), 3::bigint, 'staff ve rutas de su empresa');
select lives_ok($$insert into public.routes (operator_id, school_id, vehicle_id, shift) values
  ('00000000-0000-0000-0000-00000007aaaa', '00000000-0000-0000-0000-0000000072a1',
   '00000000-0000-0000-0000-0000000071a2', 'am')$$, 'staff crea ruta en su empresa');
select lives_ok($$update public.routes set active = false
  where id = '00000000-0000-0000-0000-0000000073a2'$$, 'staff desactiva ruta');
select throws_ok('delete from public.routes', '42501', null, 'staff no borra rutas');
reset role;

-- X: owner de B
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000007b1","role":"authenticated"}';
select is_empty($$select 1 from public.routes
  where operator_id = '00000000-0000-0000-0000-00000007aaaa'$$, 'X no ve rutas de A');
reset role;

-- resultados de escrituras
select is((select shift::text from public.routes where id = '00000000-0000-0000-0000-0000000073a1'), 'pm',
  'edición del owner persistida');
select is((select vehicle_id from public.routes where id = '00000000-0000-0000-0000-0000000073a1'),
  '00000000-0000-0000-0000-0000000071a1'::uuid, 'ruta conserva su buseta');
select is((select shift::text from public.routes where id = '00000000-0000-0000-0000-0000000073b1'), 'am',
  'owner de A no edita ruta de B');
select is((select active from public.routes where id = '00000000-0000-0000-0000-0000000073a2'), false,
  'desactivación de staff persistida');
select has_trigger('public', 'routes', 'routes_set_updated_at', 'updated_at se mantiene por trigger');

select * from finish();
rollback;
