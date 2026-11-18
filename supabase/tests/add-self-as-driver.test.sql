-- ATDE-17-T03: el owner se marca chofer de su empresa (owner + driver); nadie más.
-- Empresa A: O owner, P owner con driver inactivo, S staff, D driver. Empresa B: B owner.
begin;
create extension if not exists pgtap with schema extensions;
select plan(11);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000017c1', '50617100001'),  -- O
  ('00000000-0000-0000-0000-0000000017c2', '50617100002'),  -- P
  ('00000000-0000-0000-0000-0000000017c3', '50617100003'),  -- S
  ('00000000-0000-0000-0000-0000000017c4', '50617100004'),  -- D
  ('00000000-0000-0000-0000-0000000017d1', '50617100005');  -- B
insert into public.operators (id, name, country, currency, timezone) values
  ('00000000-0000-0000-0000-00000017cccc', 'Busetas A', 'CR', 'CRC', 'America/Costa_Rica'),
  ('00000000-0000-0000-0000-00000017dddd', 'Busetas B', 'CR', 'CRC', 'America/Costa_Rica');
insert into public.memberships (profile_id, operator_id, role, active) values
  ('00000000-0000-0000-0000-0000000017c1', '00000000-0000-0000-0000-00000017cccc', 'owner', true),
  ('00000000-0000-0000-0000-0000000017c2', '00000000-0000-0000-0000-00000017cccc', 'owner', true),
  ('00000000-0000-0000-0000-0000000017c2', '00000000-0000-0000-0000-00000017cccc', 'driver', false),
  ('00000000-0000-0000-0000-0000000017c3', '00000000-0000-0000-0000-00000017cccc', 'staff', true),
  ('00000000-0000-0000-0000-0000000017c4', '00000000-0000-0000-0000-00000017cccc', 'driver', true),
  ('00000000-0000-0000-0000-0000000017d1', '00000000-0000-0000-0000-00000017dddd', 'owner', true);

select ok((select prosecdef and proconfig @> array['search_path=""'] from pg_proc
  where oid = 'public.add_self_as_driver(uuid)'::regprocedure),
  'add_self_as_driver es security definer con search_path vacío');

set local role anon;
select throws_ok($$select public.add_self_as_driver('00000000-0000-0000-0000-00000017cccc')$$,
  '42501', null, 'anon no se marca chofer');
reset role;

set local role authenticated;
set local request.jwt.claims = '{"role":"authenticated"}';
select throws_ok($$select public.add_self_as_driver('00000000-0000-0000-0000-00000017cccc')$$,
  '28000', null, 'sin sesión no se marca chofer');
reset role;

-- O: owner se marca chofer; repetirlo no duplica
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000017c1","role":"authenticated"}';
select isnt(public.add_self_as_driver('00000000-0000-0000-0000-00000017cccc'), null,
  'owner se marca chofer y recibe el id');
select is(public.add_self_as_driver('00000000-0000-0000-0000-00000017cccc'),
  (select id from public.memberships where profile_id = '00000000-0000-0000-0000-0000000017c1' and role = 'driver'),
  'repetirlo devuelve la misma membership');
reset role;

-- P: owner con driver inactivo lo reactiva
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000017c2","role":"authenticated"}';
select lives_ok($$select public.add_self_as_driver('00000000-0000-0000-0000-00000017cccc')$$,
  'owner con rol chofer inactivo lo reactiva');
reset role;

-- S, D y B: no pueden
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000017c3","role":"authenticated"}';
select throws_ok($$select public.add_self_as_driver('00000000-0000-0000-0000-00000017cccc')$$,
  '42501', null, 'staff no se marca chofer');
reset role;
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000017c4","role":"authenticated"}';
select throws_ok($$select public.add_self_as_driver('00000000-0000-0000-0000-00000017cccc')$$,
  '42501', null, 'chofer no usa la función');
reset role;
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000017d1","role":"authenticated"}';
select throws_ok($$select public.add_self_as_driver('00000000-0000-0000-0000-00000017cccc')$$,
  '42501', null, 'owner de otra empresa no se marca chofer en A');
reset role;

-- resultados
select results_eq($$select profile_id, role, active from public.memberships
  where operator_id = '00000000-0000-0000-0000-00000017cccc'
    and profile_id in ('00000000-0000-0000-0000-0000000017c1', '00000000-0000-0000-0000-0000000017c2')
  order by profile_id, role$$,
  $$values ('00000000-0000-0000-0000-0000000017c1'::uuid, 'owner'::public.membership_role, true),
           ('00000000-0000-0000-0000-0000000017c1', 'driver', true),
           ('00000000-0000-0000-0000-0000000017c2', 'owner', true),
           ('00000000-0000-0000-0000-0000000017c2', 'driver', true)$$,
  'owners quedan con dos roles activos');
select is((select count(*) from public.memberships where operator_id = '00000000-0000-0000-0000-00000017cccc'
    and role = 'driver' and profile_id in ('00000000-0000-0000-0000-0000000017c3', '00000000-0000-0000-0000-0000000017d1')),
  0::bigint, 'rechazados no ganan rol chofer');

select * from finish();
rollback;
