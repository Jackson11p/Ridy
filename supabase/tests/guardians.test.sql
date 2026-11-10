-- ATDE-10-T02: vínculos encargado-estudiante (guardians) y RLS owner/staff/driver.
-- Visibilidad del padre en guardians-parent.test.sql.
-- Empresa A: O owner, S staff, D driver, P1 encargado activo de SA, P2 vínculo inactivo con SA. Empresa B: X owner, PB.
begin;
create extension if not exists pgtap with schema extensions;
select plan(31);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000011a1', '50652000001'),  -- O
  ('00000000-0000-0000-0000-0000000011a2', '50652000002'),  -- S
  ('00000000-0000-0000-0000-0000000011a3', '50652000003'),  -- D
  ('00000000-0000-0000-0000-0000000011a4', '50652000004'),  -- P1
  ('00000000-0000-0000-0000-0000000011a5', '50652000005'),  -- P2
  ('00000000-0000-0000-0000-0000000011b1', '50652000006'),  -- X
  ('00000000-0000-0000-0000-0000000011b2', '50652000007');  -- PB
insert into public.operators (id, name, country, currency, timezone) values
  ('00000000-0000-0000-0000-00000011aaaa', 'Busetas A', 'CR', 'CRC', 'America/Costa_Rica'),
  ('00000000-0000-0000-0000-00000011bbbb', 'Busetas B', 'CR', 'CRC', 'America/Costa_Rica');
insert into public.memberships (profile_id, operator_id, role) values
  ('00000000-0000-0000-0000-0000000011a1', '00000000-0000-0000-0000-00000011aaaa', 'owner'),
  ('00000000-0000-0000-0000-0000000011a2', '00000000-0000-0000-0000-00000011aaaa', 'staff'),
  ('00000000-0000-0000-0000-0000000011a3', '00000000-0000-0000-0000-00000011aaaa', 'driver'),
  ('00000000-0000-0000-0000-0000000011b1', '00000000-0000-0000-0000-00000011bbbb', 'owner');
insert into public.schools (id, operator_id, name, location)
select id::uuid, op::uuid, 'Colegio',
  extensions.st_setsrid(extensions.st_makepoint(-84.09, 9.93), 4326)::extensions.geography
from (values ('00000000-0000-0000-0000-0000000111a1', '00000000-0000-0000-0000-00000011aaaa'),
  ('00000000-0000-0000-0000-0000000111b1', '00000000-0000-0000-0000-00000011bbbb')) as s (id, op);
insert into public.students (id, operator_id, school_id, full_name) values
  ('00000000-0000-0000-0000-0000000112a1', '00000000-0000-0000-0000-00000011aaaa',
   '00000000-0000-0000-0000-0000000111a1', 'SA'),
  ('00000000-0000-0000-0000-0000000112b1', '00000000-0000-0000-0000-00000011bbbb',
   '00000000-0000-0000-0000-0000000111b1', 'SB');
insert into public.guardians (id, operator_id, student_id, profile_id, relationship, active) values
  ('00000000-0000-0000-0000-0000000113a1', '00000000-0000-0000-0000-00000011aaaa',
   '00000000-0000-0000-0000-0000000112a1', '00000000-0000-0000-0000-0000000011a4', 'mother', true),
  ('00000000-0000-0000-0000-0000000113a2', '00000000-0000-0000-0000-00000011aaaa',
   '00000000-0000-0000-0000-0000000112a1', '00000000-0000-0000-0000-0000000011a5', 'father', false),
  ('00000000-0000-0000-0000-0000000113b1', '00000000-0000-0000-0000-00000011bbbb',
   '00000000-0000-0000-0000-0000000112b1', '00000000-0000-0000-0000-0000000011b2', 'other', true);

-- estructura y checks
select enum_has_labels('public', 'guardian_relationship',
  array['mother', 'father', 'grandparent', 'legal_guardian', 'other'], 'relaciones permitidas');
select has_index('public', 'guardians', 'guardians_profile_id_idx', 'índice por encargado');
select has_trigger('public', 'guardians', 'guardians_set_updated_at', 'updated_at se mantiene por trigger');
select is((select receives_notifications from public.guardians where id = '00000000-0000-0000-0000-0000000113a1'),
  true, 'recibe avisos por defecto');
select throws_ok($$insert into public.guardians (operator_id, student_id, profile_id, relationship) values
  ('00000000-0000-0000-0000-00000011aaaa', '00000000-0000-0000-0000-0000000112a1',
   '00000000-0000-0000-0000-0000000011a4', 'father')$$, '23505', null, 'vínculo duplicado rechazado');
select throws_ok($$insert into public.guardians (operator_id, student_id, profile_id, relationship) values
  ('00000000-0000-0000-0000-00000011aaaa', '00000000-0000-0000-0000-0000000112b1',
   '00000000-0000-0000-0000-0000000011a5', 'father')$$, '23503', null, 'vínculo con estudiante de otra empresa rechazado');
select throws_ok($$update public.guardians set student_id = '00000000-0000-0000-0000-0000000112b1'
  where id = '00000000-0000-0000-0000-0000000113a1'$$, '23503', null, 'vínculo no se mueve a estudiante de otra empresa');
select throws_ok($$insert into public.guardians (operator_id, student_id, profile_id) values
  ('00000000-0000-0000-0000-00000011aaaa', '00000000-0000-0000-0000-0000000112a1',
   '00000000-0000-0000-0000-0000000011a1')$$, '23502', null, 'relación obligatoria');

-- anon
set local role anon;
select throws_ok('select 1 from public.guardians', '42501', null, 'anon no ve vínculos');
reset role;

-- O: owner de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000011a1","role":"authenticated"}';
select is((select count(*) from public.guardians), 2::bigint, 'owner ve vínculos de su empresa, incluso inactivos');
select is((select phone from public.profiles where id = '00000000-0000-0000-0000-0000000011a4'), '50652000004',
  'owner ve el perfil del encargado activo');
select is_empty($$select 1 from public.profiles where id = '00000000-0000-0000-0000-0000000011a5'$$,
  'owner no ve perfil de vínculo inactivo');
select is_empty($$select 1 from public.profiles where id = '00000000-0000-0000-0000-0000000011b2'$$,
  'owner no ve encargados de otra empresa');
select throws_ok($$select push_token from public.profiles where id = '00000000-0000-0000-0000-0000000011a4'$$,
  '42501', null, 'owner no lee push_token del encargado');
select throws_ok($$insert into public.guardians (operator_id, student_id, profile_id, relationship) values
  ('00000000-0000-0000-0000-00000011aaaa', '00000000-0000-0000-0000-0000000112a1',
   '00000000-0000-0000-0000-0000000011a2', 'other')$$, '42501', null, 'cliente no crea vínculos');
select throws_ok($$update public.guardians set receives_notifications = false
  where id = '00000000-0000-0000-0000-0000000113a1'$$, '42501', null, 'owner no cambia los avisos del encargado');
select lives_ok($$update public.guardians set active = false
  where id = '00000000-0000-0000-0000-0000000113a1'$$, 'owner desactiva vínculo');
select throws_ok($$update public.guardians set operator_id = '00000000-0000-0000-0000-00000011bbbb'$$,
  '42501', null, 'owner no mueve vínculos a otra empresa');
select throws_ok($$update public.guardians set id = gen_random_uuid()$$, '42501', null, 'nadie cambia el id');
update public.guardians set active = false where id = '00000000-0000-0000-0000-0000000113b1';
select throws_ok('delete from public.guardians', '42501', null, 'nadie borra vínculos');
reset role;

-- S: staff de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000011a2","role":"authenticated"}';
select is((select count(*) from public.guardians), 2::bigint, 'staff ve vínculos de su empresa');
select lives_ok($$update public.guardians set active = true
  where id = '00000000-0000-0000-0000-0000000113a2'$$, 'staff reactiva vínculo');
reset role;

-- X: owner de B
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000011b1","role":"authenticated"}';
select is_empty($$select 1 from public.guardians
  where operator_id = '00000000-0000-0000-0000-00000011aaaa'$$, 'X no ve vínculos de A');
select is_empty($$select 1 from public.profiles where id = '00000000-0000-0000-0000-0000000011a5'$$,
  'X no ve encargados de A');
reset role;

-- D: driver de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000011a3","role":"authenticated"}';
select is_empty('select 1 from public.students', 'driver no ve estudiantes');
select is_empty('select 1 from public.guardians', 'driver no ve vínculos');
reset role;

-- resultados de escrituras
select is((select active from public.guardians where id = '00000000-0000-0000-0000-0000000113a1'), false,
  'desactivación del owner persistida');
select is((select receives_notifications from public.guardians where id = '00000000-0000-0000-0000-0000000113a1'),
  true, 'avisos del encargado intactos');
select is((select active from public.guardians where id = '00000000-0000-0000-0000-0000000113a2'), true,
  'reactivación de staff persistida');
select is((select active from public.guardians where id = '00000000-0000-0000-0000-0000000113b1'), true,
  'owner de A no edita vínculo de B');
select is((select student_id from public.guardians where id = '00000000-0000-0000-0000-0000000113a1'),
  '00000000-0000-0000-0000-0000000112a1'::uuid, 'vínculo conserva su estudiante');

select * from finish();
rollback;
