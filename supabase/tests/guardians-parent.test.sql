-- ATDE-10-T02: el padre ve solo a sus hijos activos y su propio vínculo; solo cambia "recibe avisos".
-- Empresa A. P1 encargado de S1, S2 y S6 (inactivo); P2 de S3; P3 comparte S1; P4 vínculo inactivo con S4;
-- P5 perfil inactivo con vínculo activo a S5.
begin;
create extension if not exists pgtap with schema extensions;
select plan(22);

insert into auth.users (id, phone)
select ('00000000-0000-0000-0000-0000000012a' || n)::uuid, '5065300000' || n
from generate_series(1, 5) as n;
update public.profiles set active = false where id = '00000000-0000-0000-0000-0000000012a5';
insert into public.operators (id, name, country, currency, timezone) values
  ('00000000-0000-0000-0000-00000012aaaa', 'Busetas A', 'CR', 'CRC', 'America/Costa_Rica');
insert into public.schools (id, operator_id, name, location) values
  ('00000000-0000-0000-0000-0000000121a1', '00000000-0000-0000-0000-00000012aaaa', 'Colegio',
   extensions.st_setsrid(extensions.st_makepoint(-84.09, 9.93), 4326)::extensions.geography);
insert into public.students (id, operator_id, school_id, full_name, active)
select ('00000000-0000-0000-0000-0000000122a' || n)::uuid, '00000000-0000-0000-0000-00000012aaaa',
  '00000000-0000-0000-0000-0000000121a1', 'S' || n, n <> 6
from generate_series(1, 6) as n;
insert into public.guardians (operator_id, student_id, profile_id, relationship, active)
select '00000000-0000-0000-0000-00000012aaaa', ('00000000-0000-0000-0000-0000000122a' || s)::uuid,
  ('00000000-0000-0000-0000-0000000012a' || p)::uuid, 'mother', a
from (values (1, 1, true), (2, 1, true), (6, 1, true), (3, 2, true), (1, 3, true),
  (4, 4, false), (5, 5, true)) as g (s, p, a);

-- P1: dos hijos activos, uno inactivo
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000012a1","role":"authenticated"}';
select results_eq('select full_name from public.students order by full_name', $$values ('S1'), ('S2')$$,
  'padre ve solo a sus hijos activos');
select is_empty($$select 1 from public.guardians where profile_id <> '00000000-0000-0000-0000-0000000012a1'$$,
  'padre no ve el vínculo del otro encargado de su hijo');
select is((select count(*) from public.guardians), 2::bigint, 'padre ve sus vínculos con hijos activos');
select is_empty($$select 1 from public.guardians where student_id = '00000000-0000-0000-0000-0000000122a6'$$,
  'padre no ve su vínculo con estudiante inactivo');
select is_empty($$select 1 from public.profiles where id = '00000000-0000-0000-0000-0000000012a3'$$,
  'padre no ve el perfil del otro encargado');
select lives_ok($$update public.guardians set receives_notifications = false
  where student_id = '00000000-0000-0000-0000-0000000122a1'$$, 'padre cambia sus avisos');
select throws_ok($$update public.guardians set active = false
  where student_id = '00000000-0000-0000-0000-0000000122a1'$$, '42501', null, 'padre no desactiva su vínculo');
select throws_ok($$update public.guardians set student_id = '00000000-0000-0000-0000-0000000122a3'$$,
  '42501', null, 'padre no cambia el estudiante del vínculo');
select throws_ok($$update public.guardians set relationship = 'father'$$, '42501', null, 'padre no cambia la relación');
select throws_ok($$insert into public.guardians (operator_id, student_id, profile_id, relationship) values
  ('00000000-0000-0000-0000-00000012aaaa', '00000000-0000-0000-0000-0000000122a3',
   '00000000-0000-0000-0000-0000000012a1', 'father')$$, '42501', null, 'padre no se vincula a otro niño');
select throws_ok('delete from public.guardians', '42501', null, 'padre no borra vínculos');
update public.guardians set receives_notifications = false
  where profile_id = '00000000-0000-0000-0000-0000000012a3';
update public.students set full_name = 'tomado';
update public.guardians set receives_notifications = false
  where student_id = '00000000-0000-0000-0000-0000000122a6';
reset role;

-- P2: un hijo
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000012a2","role":"authenticated"}';
select results_eq('select full_name from public.students', $$values ('S3')$$, 'otra familia ve solo a su hijo');
reset role;

-- P4: vínculo inactivo
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000012a4","role":"authenticated"}';
select is_empty('select 1 from public.students', 'vínculo inactivo: no ve al niño');
select is_empty('select 1 from public.guardians', 'vínculo inactivo: no ve el vínculo');
reset role;

-- P5: perfil inactivo
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000012a5","role":"authenticated"}';
select is_empty('select 1 from public.students', 'perfil inactivo: no ve al niño');
select is_empty('select 1 from public.guardians', 'perfil inactivo: no ve el vínculo');
reset role;

-- P3 intenta cambiar los avisos de P1
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000012a3","role":"authenticated"}';
update public.guardians set receives_notifications = not receives_notifications
  where profile_id = '00000000-0000-0000-0000-0000000012a1';
reset role;

-- resultados de escrituras
select is((select receives_notifications from public.guardians where student_id = '00000000-0000-0000-0000-0000000122a1'
  and profile_id = '00000000-0000-0000-0000-0000000012a1'), false, 'avisos del padre persistidos');
select is((select receives_notifications from public.guardians where student_id = '00000000-0000-0000-0000-0000000122a2'
  and profile_id = '00000000-0000-0000-0000-0000000012a1'), true, 'otro encargado no cambia los avisos de P1');
select is((select receives_notifications from public.guardians where student_id = '00000000-0000-0000-0000-0000000122a1'
  and profile_id = '00000000-0000-0000-0000-0000000012a3'), true, 'padre no cambia los avisos de otro encargado');
select is((select bool_and(active) from public.guardians where profile_id = '00000000-0000-0000-0000-0000000012a1'),
  true, 'vínculos del padre siguen activos');
select is((select count(*) from public.students where full_name = 'tomado'), 0::bigint, 'padre no edita estudiantes');
select is((select receives_notifications from public.guardians where student_id = '00000000-0000-0000-0000-0000000122a6'),
  true, 'padre no edita su vínculo con estudiante inactivo');

select * from finish();
rollback;
