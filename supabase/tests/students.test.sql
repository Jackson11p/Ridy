-- ATDE-10-T01: estudiantes (students) con colegio de la misma empresa y RLS owner/staff.
-- Visibilidad del padre en guardians-parent.test.sql. Empresa A: O owner, S staff, D driver. Empresa B: X owner.
begin;
create extension if not exists pgtap with schema extensions;
select plan(25);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000010a1', '50651000001'),  -- O
  ('00000000-0000-0000-0000-0000000010a2', '50651000002'),  -- S
  ('00000000-0000-0000-0000-0000000010a3', '50651000003'),  -- D
  ('00000000-0000-0000-0000-0000000010b1', '50651000004');  -- X
insert into public.operators (id, name, country, currency, timezone) values
  ('00000000-0000-0000-0000-00000010aaaa', 'Busetas A', 'CR', 'CRC', 'America/Costa_Rica'),
  ('00000000-0000-0000-0000-00000010bbbb', 'Busetas B', 'CR', 'CRC', 'America/Costa_Rica');
insert into public.memberships (profile_id, operator_id, role) values
  ('00000000-0000-0000-0000-0000000010a1', '00000000-0000-0000-0000-00000010aaaa', 'owner'),
  ('00000000-0000-0000-0000-0000000010a2', '00000000-0000-0000-0000-00000010aaaa', 'staff'),
  ('00000000-0000-0000-0000-0000000010a3', '00000000-0000-0000-0000-00000010aaaa', 'driver'),
  ('00000000-0000-0000-0000-0000000010b1', '00000000-0000-0000-0000-00000010bbbb', 'owner');
insert into public.schools (id, operator_id, name, location)
select id::uuid, op::uuid, name,
  extensions.st_setsrid(extensions.st_makepoint(-84.09, 9.93), 4326)::extensions.geography
from (values
  ('00000000-0000-0000-0000-0000000101a1', '00000000-0000-0000-0000-00000010aaaa', 'Colegio A1'),
  ('00000000-0000-0000-0000-0000000101b1', '00000000-0000-0000-0000-00000010bbbb', 'Colegio B1')
) as s (id, op, name);
insert into public.students (id, operator_id, school_id, full_name) values
  ('00000000-0000-0000-0000-0000000102a1', '00000000-0000-0000-0000-00000010aaaa',
   '00000000-0000-0000-0000-0000000101a1', 'Ana A'),
  ('00000000-0000-0000-0000-0000000102b1', '00000000-0000-0000-0000-00000010bbbb',
   '00000000-0000-0000-0000-0000000101b1', 'Beto B');

-- estructura: datos mínimos del menor, sin columnas sensibles
select columns_are('public', 'students',
  array['id', 'operator_id', 'school_id', 'full_name', 'active', 'created_at', 'updated_at'],
  'students solo guarda nombre, colegio y estado');
select is((select active from public.students where full_name = 'Ana A'), true, 'estudiante activo por defecto');
select has_index('public', 'students', 'students_operator_id_idx', 'índice por empresa');
select has_trigger('public', 'students', 'students_set_updated_at', 'updated_at se mantiene por trigger');
select throws_ok($$insert into public.students (operator_id, school_id, full_name) values
  ('00000000-0000-0000-0000-00000010aaaa', '00000000-0000-0000-0000-0000000101a1', '  ')$$,
  '23514', null, 'nombre vacío rechazado');
select throws_ok($$insert into public.students (operator_id, school_id, full_name) values
  ('00000000-0000-0000-0000-00000010aaaa', null, 'Sin colegio')$$, '23502', null, 'colegio obligatorio');

-- anon
set local role anon;
select throws_ok('select 1 from public.students', '42501', null, 'anon no ve estudiantes');
reset role;

-- O: owner de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000010a1","role":"authenticated"}';
select results_eq('select full_name from public.students', $$values ('Ana A')$$,
  'owner ve solo estudiantes de su empresa');
select lives_ok($$insert into public.students (operator_id, school_id, full_name) values
  ('00000000-0000-0000-0000-00000010aaaa', '00000000-0000-0000-0000-0000000101a1', 'Carla A')$$,
  'owner crea estudiante en su empresa');
select throws_ok($$insert into public.students (operator_id, school_id, full_name) values
  ('00000000-0000-0000-0000-00000010bbbb', '00000000-0000-0000-0000-0000000101b1', 'Intruso')$$,
  '42501', null, 'owner no crea estudiante en otra empresa');
select throws_ok($$insert into public.students (operator_id, school_id, full_name) values
  ('00000000-0000-0000-0000-00000010aaaa', '00000000-0000-0000-0000-0000000101b1', 'Cruzado')$$,
  '23503', null, 'estudiante con colegio de otra empresa rechazado');
select lives_ok($$update public.students set full_name = 'Ana Alfa'
  where id = '00000000-0000-0000-0000-0000000102a1'$$, 'owner edita estudiante de su empresa');
select throws_ok($$update public.students set school_id = '00000000-0000-0000-0000-0000000101b1'
  where id = '00000000-0000-0000-0000-0000000102a1'$$, '23503', null,
  'owner no apunta estudiante a colegio de otra empresa');
update public.students set full_name = 'tomado' where id = '00000000-0000-0000-0000-0000000102b1';
select throws_ok($$update public.students set operator_id = '00000000-0000-0000-0000-00000010bbbb'$$,
  '42501', null, 'owner no mueve estudiantes a otra empresa');
select throws_ok($$update public.students set id = gen_random_uuid()$$, '42501', null, 'nadie cambia el id');
select throws_ok('delete from public.students', '42501', null, 'nadie borra estudiantes');
reset role;

-- S: staff de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000010a2","role":"authenticated"}';
select is((select count(*) from public.students), 2::bigint, 'staff ve estudiantes de su empresa');
select lives_ok($$update public.students set active = false where full_name = 'Carla A'$$,
  'staff desactiva estudiante');
reset role;

-- X: owner de B
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000010b1","role":"authenticated"}';
select is_empty($$select 1 from public.students
  where operator_id = '00000000-0000-0000-0000-00000010aaaa'$$, 'X no ve estudiantes de A');
update public.students set full_name = 'tomado' where id = '00000000-0000-0000-0000-0000000102a1';
reset role;

-- D: driver de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000010a3","role":"authenticated"}';
select is_empty('select 1 from public.students', 'driver no ve estudiantes');
select throws_ok($$insert into public.students (operator_id, school_id, full_name) values
  ('00000000-0000-0000-0000-00000010aaaa', '00000000-0000-0000-0000-0000000101a1', 'Por driver')$$,
  '42501', null, 'driver no crea estudiantes');
reset role;

-- resultados de escrituras
select is((select full_name from public.students where id = '00000000-0000-0000-0000-0000000102b1'), 'Beto B',
  'owner de A no edita estudiante de B');
select is((select full_name from public.students where id = '00000000-0000-0000-0000-0000000102a1'), 'Ana Alfa',
  'X no edita estudiante de A');
select is((select active from public.students where full_name = 'Carla A'), false, 'desactivación de staff persistida');
select is((select school_id from public.students where id = '00000000-0000-0000-0000-0000000102a1'),
  '00000000-0000-0000-0000-0000000101a1'::uuid, 'estudiante conserva su colegio');

select * from finish();
rollback;
