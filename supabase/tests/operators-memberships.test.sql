-- ATDE-8-T02: operators, memberships y visibilidad por rol.
-- Empresa A: O owner+driver, S staff, D driver. Empresa B: X owner.
begin;
create extension if not exists pgtap with schema extensions;
select plan(28);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000a1', '50670000001'),  -- O
  ('00000000-0000-0000-0000-0000000000a2', '50670000002'),  -- S
  ('00000000-0000-0000-0000-0000000000a3', '50670000003'),  -- D
  ('00000000-0000-0000-0000-0000000000b1', '50670000004');  -- X
insert into public.operators (id, name, country, currency, timezone) values
  ('00000000-0000-0000-0000-00000000aaaa', 'Busetas A', 'CR', 'CRC', 'America/Costa_Rica'),
  ('00000000-0000-0000-0000-00000000bbbb', 'Busetas B', 'CR', 'CRC', 'America/Costa_Rica');
insert into public.memberships (profile_id, operator_id, role) values
  ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-00000000aaaa', 'owner'),
  ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-00000000aaaa', 'driver'),
  ('00000000-0000-0000-0000-0000000000a2', '00000000-0000-0000-0000-00000000aaaa', 'staff'),
  ('00000000-0000-0000-0000-0000000000a3', '00000000-0000-0000-0000-00000000aaaa', 'driver'),
  ('00000000-0000-0000-0000-0000000000b1', '00000000-0000-0000-0000-00000000bbbb', 'owner');

select is((select plan from public.operators where name = 'Busetas A'), 'beta', 'plan por defecto beta');
select throws_ok($$insert into public.memberships (profile_id, operator_id, role) values
  ('00000000-0000-0000-0000-0000000000a3', '00000000-0000-0000-0000-00000000aaaa', 'driver')$$,
  '23505', null, 'mismo rol repetido en la misma empresa no se permite');

-- anon
set local role anon;
select throws_ok('select 1 from public.operators', '42501', null, 'anon no ve empresas');
select throws_ok('select 1 from public.memberships', '42501', null, 'anon no ve memberships');
reset role;

-- O: owner (y driver) de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}';
select is((select count(*) from public.operators), 1::bigint, 'owner ve solo su empresa');
select is((select count(*) from public.memberships), 4::bigint, 'owner ve memberships de su empresa');
select is((select count(*) from public.profiles), 3::bigint, 'owner ve perfiles de sus miembros');
select lives_ok($$update public.operators set name = 'Busetas A2'
  where id = '00000000-0000-0000-0000-00000000aaaa'$$, 'owner edita su empresa');
update public.operators set name = 'tomada' where id = '00000000-0000-0000-0000-00000000bbbb';
select throws_ok($$update public.operators set plan = 'gratis'$$, '42501', null, 'owner no cambia el plan');
select throws_ok($$insert into public.operators (name, country, currency, timezone)
  values ('x', 'CR', 'CRC', 'UTC')$$, '42501', null, 'insert directo de empresa prohibido');
select throws_ok($$insert into public.memberships (profile_id, operator_id, role) values
  ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-00000000bbbb', 'owner')$$,
  '42501', null, 'insert directo de membership prohibido');
select throws_ok($$update public.memberships set role = 'owner'$$, '42501', null, 'owner no edita memberships');
select throws_ok('delete from public.memberships', '42501', null, 'nadie borra memberships');
select throws_ok('delete from public.operators', '42501', null, 'nadie borra empresas');
reset role;

-- S: staff de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}';
select is((select count(*) from public.operators), 1::bigint, 'staff ve su empresa');
select is((select count(*) from public.memberships), 4::bigint, 'staff ve memberships de su empresa');
select is((select count(*) from public.profiles), 3::bigint, 'staff ve perfiles de sus miembros');
update public.operators set name = 'por staff' where id = '00000000-0000-0000-0000-00000000aaaa';
reset role;

-- D: driver de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}';
select is((select count(*) from public.operators), 1::bigint, 'driver ve su empresa');
select is((select count(*) from public.memberships), 1::bigint, 'driver ve solo sus memberships');
select is_empty($$select 1 from public.memberships
  where profile_id <> '00000000-0000-0000-0000-0000000000a3'$$, 'driver no ve memberships de otros');
select is((select count(*) from public.profiles), 1::bigint, 'driver ve solo su perfil');
reset role;

-- X: owner de B
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000b1","role":"authenticated"}';
select is((select name from public.operators), 'Busetas B', 'X ve solo empresa B');
select is_empty($$select 1 from public.memberships
  where operator_id = '00000000-0000-0000-0000-00000000aaaa'$$, 'X no ve memberships de A');
select is((select count(*) from public.profiles), 1::bigint, 'X no ve perfiles de A');
reset role;

-- resultados de escrituras
select is((select name from public.operators where id = '00000000-0000-0000-0000-00000000aaaa'),
  'Busetas A2', 'edición del owner persistida; staff no edita');
select is((select name from public.operators where id = '00000000-0000-0000-0000-00000000bbbb'),
  'Busetas B', 'owner de A no edita empresa B');

-- membership inactiva no da acceso
update public.memberships set active = false where profile_id = '00000000-0000-0000-0000-0000000000a3';
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}';
select is((select count(*) from public.operators), 0::bigint, 'driver desactivado no ve la empresa');
select is((select count(*) from public.memberships), 1::bigint, 'driver desactivado ve su membership');
reset role;

select * from finish();
rollback;
