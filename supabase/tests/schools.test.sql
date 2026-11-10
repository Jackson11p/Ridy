-- ATDE-9-T02: colegios (schools) con punto geográfico, geocerca y RLS owner/staff.
-- Empresa A: O owner, S staff, D driver. Empresa B: X owner.
begin;
create extension if not exists pgtap with schema extensions;
select plan(22);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000008a1', '50620000001'),  -- O
  ('00000000-0000-0000-0000-0000000008a2', '50620000002'),  -- S
  ('00000000-0000-0000-0000-0000000008a3', '50620000003'),  -- D
  ('00000000-0000-0000-0000-0000000008b1', '50620000004');  -- X
insert into public.operators (id, name, country, currency, timezone) values
  ('00000000-0000-0000-0000-00000008aaaa', 'Busetas A', 'CR', 'CRC', 'America/Costa_Rica'),
  ('00000000-0000-0000-0000-00000008bbbb', 'Busetas B', 'CR', 'CRC', 'America/Costa_Rica');
insert into public.memberships (profile_id, operator_id, role) values
  ('00000000-0000-0000-0000-0000000008a1', '00000000-0000-0000-0000-00000008aaaa', 'owner'),
  ('00000000-0000-0000-0000-0000000008a2', '00000000-0000-0000-0000-00000008aaaa', 'staff'),
  ('00000000-0000-0000-0000-0000000008a3', '00000000-0000-0000-0000-00000008aaaa', 'driver'),
  ('00000000-0000-0000-0000-0000000008b1', '00000000-0000-0000-0000-00000008bbbb', 'owner');
insert into public.schools (id, operator_id, name, location) values
  ('00000000-0000-0000-0000-0000000081a1', '00000000-0000-0000-0000-00000008aaaa', 'Colegio A1',
   extensions.st_setsrid(extensions.st_makepoint(-84.0907, 9.9281), 4326)::extensions.geography),
  ('00000000-0000-0000-0000-0000000081b1', '00000000-0000-0000-0000-00000008bbbb', 'Colegio B1',
   extensions.st_setsrid(extensions.st_makepoint(-84.0500, 9.9000), 4326)::extensions.geography);

select is((select geofence_radius_m from public.schools where name = 'Colegio A1'), 200, 'geocerca por defecto 200 m');
select is((select active from public.schools where name = 'Colegio A1'), true, 'colegio activo por defecto');
select is((select round(extensions.st_y(location::extensions.geometry)::numeric, 4) from public.schools
  where name = 'Colegio A1'), 9.9281, 'ubicación guarda la latitud');
select has_index('public', 'schools', 'schools_location_idx', 'índice GIST en ubicación');

-- checks
select throws_ok($$insert into public.schools (operator_id, name, location, geofence_radius_m)
  values ('00000000-0000-0000-0000-00000008aaaa', 'R49',
  extensions.st_setsrid(extensions.st_makepoint(-84, 9.9), 4326)::extensions.geography, 49)$$,
  '23514', null, 'geocerca menor a 50 m rechazada');
select throws_ok($$insert into public.schools (operator_id, name, location, geofence_radius_m)
  values ('00000000-0000-0000-0000-00000008aaaa', 'R2001',
  extensions.st_setsrid(extensions.st_makepoint(-84, 9.9), 4326)::extensions.geography, 2001)$$,
  '23514', null, 'geocerca mayor a 2000 m rechazada');
select throws_ok($$insert into public.schools (operator_id, name, location)
  values ('00000000-0000-0000-0000-00000008aaaa', ' ',
  extensions.st_setsrid(extensions.st_makepoint(-84, 9.9), 4326)::extensions.geography)$$,
  '23514', null, 'nombre vacío rechazado');
select throws_ok($$insert into public.schools (operator_id, name)
  values ('00000000-0000-0000-0000-00000008aaaa', 'Sin punto')$$, '23502', null, 'ubicación obligatoria');

-- anon
set local role anon;
select throws_ok('select 1 from public.schools', '42501', null, 'anon no ve colegios');
reset role;

-- O: owner de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000008a1","role":"authenticated"}';
select results_eq('select name from public.schools', $$values ('Colegio A1')$$, 'owner ve solo colegios de su empresa');
select lives_ok($$insert into public.schools (operator_id, name, location, geofence_radius_m)
  values ('00000000-0000-0000-0000-00000008aaaa', 'Colegio A2',
  extensions.st_setsrid(extensions.st_makepoint(-84.1, 9.95), 4326)::extensions.geography, 300)$$,
  'owner crea colegio en su empresa');
select throws_ok($$insert into public.schools (operator_id, name, location)
  values ('00000000-0000-0000-0000-00000008bbbb', 'Intruso',
  extensions.st_setsrid(extensions.st_makepoint(-84, 9.9), 4326)::extensions.geography)$$,
  '42501', null, 'owner no crea colegio en otra empresa');
select lives_ok($$update public.schools set geofence_radius_m = 250 where name = 'Colegio A1'$$,
  'owner edita colegio de su empresa');
update public.schools set name = 'tomado' where id = '00000000-0000-0000-0000-0000000081b1';
select throws_ok($$update public.schools set operator_id = '00000000-0000-0000-0000-00000008bbbb'$$,
  '42501', null, 'owner no mueve colegios a otra empresa');
select throws_ok('delete from public.schools', '42501', null, 'nadie borra colegios');
reset role;

-- S: staff de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000008a2","role":"authenticated"}';
select is((select count(*) from public.schools), 2::bigint, 'staff ve colegios de su empresa');
select lives_ok($$update public.schools set active = false where name = 'Colegio A2'$$, 'staff desactiva colegio');
reset role;

-- X: owner de B
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000008b1","role":"authenticated"}';
select is_empty($$select 1 from public.schools
  where operator_id = '00000000-0000-0000-0000-00000008aaaa'$$, 'X no ve colegios de A');
reset role;

-- D: driver de A sin rutas
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000008a3","role":"authenticated"}';
select is((select count(*) from public.schools), 0::bigint, 'driver sin rutas no ve colegios');
select throws_ok($$insert into public.schools (operator_id, name, location)
  values ('00000000-0000-0000-0000-00000008aaaa', 'Por driver',
  extensions.st_setsrid(extensions.st_makepoint(-84, 9.9), 4326)::extensions.geography)$$,
  '42501', null, 'driver no crea colegios');
reset role;

-- resultados de escrituras
select is((select name from public.schools where id = '00000000-0000-0000-0000-0000000081b1'), 'Colegio B1',
  'owner de A no edita colegio de B');
select is((select active from public.schools where name = 'Colegio A2'), false, 'desactivación de staff persistida');

select * from finish();
rollback;
