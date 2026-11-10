-- ATDE-10-T03: RLS de invitaciones: owner/staff crean de estudiante y solo (des)activan; nadie más las ve.
-- Empresa A: O owner, S staff, D driver, P padre de SA1, I invitado (teléfono de IA1). Empresa B: X owner.
begin;
create extension if not exists pgtap with schema extensions;
select plan(30);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000014a1', '50654100001'),  -- O
  ('00000000-0000-0000-0000-0000000014a2', '50654100002'),  -- S
  ('00000000-0000-0000-0000-0000000014a3', '50654100003'),  -- D
  ('00000000-0000-0000-0000-0000000014a4', '50654100004'),  -- P
  ('00000000-0000-0000-0000-0000000014a5', '50654100010'),  -- I
  ('00000000-0000-0000-0000-0000000014b1', '50654100005');  -- X
insert into public.operators (id, name, country, currency, timezone) values
  ('00000000-0000-0000-0000-00000014aaaa', 'Busetas A', 'CR', 'CRC', 'America/Costa_Rica'),
  ('00000000-0000-0000-0000-00000014bbbb', 'Busetas B', 'CR', 'CRC', 'America/Costa_Rica');
insert into public.memberships (profile_id, operator_id, role) values
  ('00000000-0000-0000-0000-0000000014a1', '00000000-0000-0000-0000-00000014aaaa', 'owner'),
  ('00000000-0000-0000-0000-0000000014a2', '00000000-0000-0000-0000-00000014aaaa', 'staff'),
  ('00000000-0000-0000-0000-0000000014a3', '00000000-0000-0000-0000-00000014aaaa', 'driver'),
  ('00000000-0000-0000-0000-0000000014b1', '00000000-0000-0000-0000-00000014bbbb', 'owner');
insert into public.schools (id, operator_id, name, location)
select id::uuid, op::uuid, 'Colegio',
  extensions.st_setsrid(extensions.st_makepoint(-84.09, 9.93), 4326)::extensions.geography
from (values ('00000000-0000-0000-0000-0000000141a1', '00000000-0000-0000-0000-00000014aaaa'),
  ('00000000-0000-0000-0000-0000000141b1', '00000000-0000-0000-0000-00000014bbbb')) as s (id, op);
insert into public.students (id, operator_id, school_id, full_name)
select id::uuid, op::uuid, school::uuid, name
from (values
  ('00000000-0000-0000-0000-0000000142a1', '00000000-0000-0000-0000-00000014aaaa', '00000000-0000-0000-0000-0000000141a1', 'SA1'),
  ('00000000-0000-0000-0000-0000000142a2', '00000000-0000-0000-0000-00000014aaaa', '00000000-0000-0000-0000-0000000141a1', 'SA2'),
  ('00000000-0000-0000-0000-0000000142b1', '00000000-0000-0000-0000-00000014bbbb', '00000000-0000-0000-0000-0000000141b1', 'SB')
) as s (id, op, school, name);
insert into public.guardians (operator_id, student_id, profile_id, relationship) values
  ('00000000-0000-0000-0000-00000014aaaa', '00000000-0000-0000-0000-0000000142a1',
   '00000000-0000-0000-0000-0000000014a4', 'father');
insert into public.invitations (id, operator_id, phone, student_id, relationship, invited_by) values
  ('00000000-0000-0000-0000-0000000143a1', '00000000-0000-0000-0000-00000014aaaa', '50654100010',
   '00000000-0000-0000-0000-0000000142a1', 'mother', '00000000-0000-0000-0000-0000000014a1'),
  ('00000000-0000-0000-0000-0000000143b1', '00000000-0000-0000-0000-00000014bbbb', '50654100010',
   '00000000-0000-0000-0000-0000000142b1', 'mother', '00000000-0000-0000-0000-0000000014b1');

-- anon
set local role anon;
select throws_ok('select 1 from public.invitations', '42501', null, 'anon no ve invitaciones');
reset role;

-- O: owner de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000014a1","role":"authenticated"}';
select isnt_empty($$select 1 from public.invitations where id = '00000000-0000-0000-0000-0000000143a1'$$,
  'owner ve invitaciones de su empresa');
select is_empty($$select 1 from public.invitations where operator_id = '00000000-0000-0000-0000-00000014bbbb'$$,
  'owner no ve invitaciones de otra empresa');
select lives_ok($$insert into public.invitations (operator_id, phone, student_id, relationship) values
  ('00000000-0000-0000-0000-00000014aaaa', '50654100020', '00000000-0000-0000-0000-0000000142a2', 'father')$$,
  'owner invita encargado de un estudiante');
select throws_ok($$insert into public.invitations (operator_id, phone, role) values
  ('00000000-0000-0000-0000-00000014aaaa', '50654100021', 'driver')$$, '42501', null, 'cliente no crea invitación de rol');
select throws_ok($$insert into public.invitations (operator_id, phone, student_id, relationship, invited_by) values
  ('00000000-0000-0000-0000-00000014aaaa', '50654100022', '00000000-0000-0000-0000-0000000142a2', 'father',
   '00000000-0000-0000-0000-0000000014a2')$$, '42501', null, 'cliente no fija quién invita');
select throws_ok($$insert into public.invitations (operator_id, phone, student_id, relationship, expires_at) values
  ('00000000-0000-0000-0000-00000014aaaa', '50654100022', '00000000-0000-0000-0000-0000000142a2', 'father',
   now() + interval '1 year')$$, '42501', null, 'cliente no fija el vencimiento');
select throws_ok($$insert into public.invitations (operator_id, phone, student_id, relationship, accepted_at) values
  ('00000000-0000-0000-0000-00000014aaaa', '50654100022', '00000000-0000-0000-0000-0000000142a2', 'father',
   now())$$, '42501', null, 'cliente no crea invitaciones aceptadas');
select throws_ok($$insert into public.invitations (operator_id, phone, student_id, relationship) values
  ('00000000-0000-0000-0000-00000014bbbb', '50654100022', '00000000-0000-0000-0000-0000000142b1', 'father')$$,
  '42501', null, 'owner no invita en otra empresa');
select throws_ok($$insert into public.invitations (operator_id, phone, student_id, relationship) values
  ('00000000-0000-0000-0000-00000014aaaa', '50654100022', '00000000-0000-0000-0000-0000000142b1', 'father')$$,
  '23503', null, 'owner no invita a estudiante de otra empresa');
select lives_ok($$update public.invitations set active = false
  where id = '00000000-0000-0000-0000-0000000143a1'$$, 'owner desactiva invitación');
select throws_ok($$update public.invitations set phone = '50654100099'$$, '42501', null, 'nadie cambia el teléfono');
select throws_ok($$update public.invitations set expires_at = now()$$, '42501', null, 'nadie cambia el vencimiento');
select throws_ok($$update public.invitations set accepted_at = now()$$, '42501', null, 'cliente no acepta invitaciones');
select throws_ok($$update public.invitations set operator_id = '00000000-0000-0000-0000-00000014bbbb'$$,
  '42501', null, 'owner no mueve invitaciones a otra empresa');
select throws_ok($$update public.invitations set id = gen_random_uuid()$$, '42501', null, 'nadie cambia el id');
update public.invitations set active = false where id = '00000000-0000-0000-0000-0000000143b1';
select throws_ok('delete from public.invitations', '42501', null, 'nadie borra invitaciones');
reset role;

-- S: staff de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000014a2","role":"authenticated"}';
select lives_ok($$insert into public.invitations (operator_id, phone, student_id, relationship) values
  ('00000000-0000-0000-0000-00000014aaaa', '50654100030', '00000000-0000-0000-0000-0000000142a1', 'grandparent')$$,
  'staff invita encargado de un estudiante');
select throws_ok($$insert into public.invitations (operator_id, phone, role) values
  ('00000000-0000-0000-0000-00000014aaaa', '50654100031', 'owner')$$, '42501', null, 'staff no invita a un owner');
select is((select count(*) from public.invitations), 3::bigint, 'staff ve invitaciones de su empresa');
reset role;

-- X: owner de B
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000014b1","role":"authenticated"}';
select is_empty($$select 1 from public.invitations
  where operator_id = '00000000-0000-0000-0000-00000014aaaa'$$, 'X no ve invitaciones de A');
update public.invitations set active = false where phone = '50654100020';
reset role;

-- D driver, P padre, I invitado: no ven invitaciones
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000014a3","role":"authenticated"}';
select is_empty('select 1 from public.invitations', 'driver no ve invitaciones');
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000014a4","role":"authenticated"}';
select is_empty('select 1 from public.invitations', 'padre no ve invitaciones');
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000014a5","role":"authenticated"}';
select is_empty('select 1 from public.invitations', 'invitado no lee su invitación');
reset role;

-- resultados de escrituras
select is((select invited_by from public.invitations where phone = '50654100020'),
  '00000000-0000-0000-0000-0000000014a1'::uuid, 'invited_by lo pone la BD (owner)');
select is((select expires_at from public.invitations where phone = '50654100020'),
  now() + interval '14 days', 'invitación del owner vence a 14 días');
select is((select invited_by from public.invitations where phone = '50654100030'),
  '00000000-0000-0000-0000-0000000014a2'::uuid, 'invited_by lo pone la BD (staff)');
select is((select active from public.invitations where id = '00000000-0000-0000-0000-0000000143a1'), false,
  'desactivación del owner persistida');
select is((select active from public.invitations where id = '00000000-0000-0000-0000-0000000143b1'), true,
  'owner de A no edita invitación de B');
select is((select active from public.invitations where phone = '50654100020'), true,
  'X no edita invitación de A');

select * from finish();
rollback;
