-- ATDE-8-T07: perfil inactivo pierde acceso; create_operator valida; quién edita empresas.
-- E: O owner, D driver. F: P owner (perfil inactivo). G: Q owner (membership inactiva).
begin;
create extension if not exists pgtap with schema extensions;
select plan(11);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000e1', '50640000001'),  -- O
  ('00000000-0000-0000-0000-0000000000e2', '50640000002'),  -- D
  ('00000000-0000-0000-0000-0000000000e3', '50640000003'),  -- P
  ('00000000-0000-0000-0000-0000000000e4', '50640000004');  -- Q
insert into public.operators (id, name, country, currency, timezone) values
  ('00000000-0000-0000-0000-00000000eeee', 'E', 'CR', 'CRC', 'America/Costa_Rica'),
  ('00000000-0000-0000-0000-00000000ffff', 'F', 'CR', 'CRC', 'America/Costa_Rica'),
  ('00000000-0000-0000-0000-000000009999', 'G', 'CR', 'CRC', 'America/Costa_Rica');
insert into public.memberships (profile_id, operator_id, role, active) values
  ('00000000-0000-0000-0000-0000000000e1', '00000000-0000-0000-0000-00000000eeee', 'owner', true),
  ('00000000-0000-0000-0000-0000000000e2', '00000000-0000-0000-0000-00000000eeee', 'driver', true),
  ('00000000-0000-0000-0000-0000000000e3', '00000000-0000-0000-0000-00000000ffff', 'owner', true),
  ('00000000-0000-0000-0000-0000000000e4', '00000000-0000-0000-0000-000000009999', 'owner', false);
update public.profiles set active = false where id = '00000000-0000-0000-0000-0000000000e3';

select ok(not has_function_privilege('authenticated', 'private.set_updated_at()', 'execute'),
  'clientes no ejecutan set_updated_at');

-- D: driver no edita empresa
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000e2","role":"authenticated"}';
update public.operators set name = 'por driver' where id = '00000000-0000-0000-0000-00000000eeee';
reset role;
select is((select name from public.operators where id = '00000000-0000-0000-0000-00000000eeee'),
  'E', 'driver no edita su empresa');

-- Q: owner con membership inactiva no edita
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000e4","role":"authenticated"}';
update public.operators set name = 'por Q' where id = '00000000-0000-0000-0000-000000009999';
reset role;
select is((select name from public.operators where id = '00000000-0000-0000-0000-000000009999'),
  'G', 'owner con membership inactiva pierde update');

-- P: perfil inactivo
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000e3","role":"authenticated"}';
select is((select count(*) from public.operators), 0::bigint, 'perfil inactivo pierde acceso a su empresa');
select throws_ok($$select public.create_operator('P2', 'CR', 'CRC', 'UTC')$$,
  '42501', null, 'perfil inactivo no crea empresas');
reset role;

-- O: validaciones y dos empresas propias
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000e1","role":"authenticated"}';
select throws_ok($$select public.create_operator('X', 'CR', 'CRC', 'foo')$$,
  '22023', null, 'timezone inválida se rechaza');
create temp table nuevas as
  select public.create_operator('E2', 'CR', 'CRC', 'America/Costa_Rica') as id
  union all
  select public.create_operator('E3', 'CR', 'CRC', 'UTC');
select is((select count(distinct id) from nuevas), 2::bigint, 'dos llamadas crean dos empresas distintas');
select is((select count(*) from public.operators), 3::bigint, 'owner ve sus tres empresas');
select is((select count(*) from public.memberships m join nuevas n on n.id = m.operator_id
  where m.role = 'owner' and m.profile_id = '00000000-0000-0000-0000-0000000000e1'), 2::bigint,
  'owner de ambas empresas nuevas');
reset role;

select is((select count(*) from public.operators where name = 'X'), 0::bigint, 'timezone inválida no deja empresa');
select is((select count(*) from public.operators where name = 'P2'), 0::bigint, 'perfil inactivo no deja empresa');

select * from finish();
rollback;
