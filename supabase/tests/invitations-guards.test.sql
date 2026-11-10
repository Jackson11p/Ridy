-- ATDE-10-T05: owner/staff solo (des)activan invitaciones de estudiante e invitan solo a estudiantes activos.
-- Empresa A: O owner, S staff; SA activo, SI inactivo; IR1 invitación de rol owner inactiva, IR2 de rol driver activa.
begin;
create extension if not exists pgtap with schema extensions;
select plan(6);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000015a1', '50654200001'),  -- O
  ('00000000-0000-0000-0000-0000000015a2', '50654200002');  -- S
insert into public.operators (id, name, country, currency, timezone) values
  ('00000000-0000-0000-0000-00000015aaaa', 'Busetas A', 'CR', 'CRC', 'America/Costa_Rica');
insert into public.memberships (profile_id, operator_id, role) values
  ('00000000-0000-0000-0000-0000000015a1', '00000000-0000-0000-0000-00000015aaaa', 'owner'),
  ('00000000-0000-0000-0000-0000000015a2', '00000000-0000-0000-0000-00000015aaaa', 'staff');
insert into public.schools (id, operator_id, name, location) values
  ('00000000-0000-0000-0000-0000000151a1', '00000000-0000-0000-0000-00000015aaaa', 'Colegio',
   extensions.st_setsrid(extensions.st_makepoint(-84.09, 9.93), 4326)::extensions.geography);
insert into public.students (id, operator_id, school_id, full_name, active) values
  ('00000000-0000-0000-0000-0000000152a1', '00000000-0000-0000-0000-00000015aaaa',
   '00000000-0000-0000-0000-0000000151a1', 'SA', true),
  ('00000000-0000-0000-0000-0000000152a2', '00000000-0000-0000-0000-00000015aaaa',
   '00000000-0000-0000-0000-0000000151a1', 'SI', false);
insert into public.invitations (id, operator_id, phone, role, invited_by, active) values
  ('00000000-0000-0000-0000-0000000153a1', '00000000-0000-0000-0000-00000015aaaa', '50654200010', 'owner',
   '00000000-0000-0000-0000-0000000015a1', false),
  ('00000000-0000-0000-0000-0000000153a2', '00000000-0000-0000-0000-00000015aaaa', '50654200011', 'driver',
   '00000000-0000-0000-0000-0000000015a1', true);

-- S: staff intenta reactivar una invitación de rol owner (escalada)
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000015a2","role":"authenticated"}';
update public.invitations set active = true where id = '00000000-0000-0000-0000-0000000153a1';
select lives_ok($$insert into public.invitations (operator_id, phone, student_id, relationship) values
  ('00000000-0000-0000-0000-00000015aaaa', '50654200020', '00000000-0000-0000-0000-0000000152a1', 'mother')$$,
  'staff invita encargado de estudiante activo');
select throws_ok($$insert into public.invitations (operator_id, phone, student_id, relationship) values
  ('00000000-0000-0000-0000-00000015aaaa', '50654200021', '00000000-0000-0000-0000-0000000152a2', 'mother')$$,
  '42501', null, 'staff no invita encargado de estudiante inactivo');
reset role;

-- O: owner intenta desactivar una invitación de rol
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000015a1","role":"authenticated"}';
update public.invitations set active = false where id = '00000000-0000-0000-0000-0000000153a2';
select throws_ok($$insert into public.invitations (operator_id, phone, student_id, relationship) values
  ('00000000-0000-0000-0000-00000015aaaa', '50654200022', '00000000-0000-0000-0000-0000000152a2', 'father')$$,
  '42501', null, 'owner no invita encargado de estudiante inactivo');
reset role;

-- resultados de escrituras
select is((select active from public.invitations where id = '00000000-0000-0000-0000-0000000153a1'), false,
  'staff no reactiva invitación de rol owner');
select is((select active from public.invitations where id = '00000000-0000-0000-0000-0000000153a2'), true,
  'owner no desactiva invitación de rol');
select is((select count(*) from public.invitations where student_id = '00000000-0000-0000-0000-0000000152a2'),
  0::bigint, 'ninguna invitación a estudiante inactivo persistida');

select * from finish();
rollback;
