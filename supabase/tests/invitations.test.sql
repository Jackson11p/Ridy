-- ATDE-10-T03: invitaciones (invitations): rol xor estudiante, teléfono, vencimiento y una pendiente por destino.
-- RLS en invitations-rls.test.sql. Empresa A: O owner, estudiantes SA1, SA2. Empresa B: X owner, SB.
begin;
create extension if not exists pgtap with schema extensions;
select plan(20);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000013a1', '50654000001'),  -- O
  ('00000000-0000-0000-0000-0000000013b1', '50654000002');  -- X
insert into public.operators (id, name, country, currency, timezone) values
  ('00000000-0000-0000-0000-00000013aaaa', 'Busetas A', 'CR', 'CRC', 'America/Costa_Rica'),
  ('00000000-0000-0000-0000-00000013bbbb', 'Busetas B', 'CR', 'CRC', 'America/Costa_Rica');
insert into public.schools (id, operator_id, name, location)
select id::uuid, op::uuid, 'Colegio',
  extensions.st_setsrid(extensions.st_makepoint(-84.09, 9.93), 4326)::extensions.geography
from (values ('00000000-0000-0000-0000-0000000131a1', '00000000-0000-0000-0000-00000013aaaa'),
  ('00000000-0000-0000-0000-0000000131b1', '00000000-0000-0000-0000-00000013bbbb')) as s (id, op);
insert into public.students (id, operator_id, school_id, full_name) values
  ('00000000-0000-0000-0000-0000000132a1', '00000000-0000-0000-0000-00000013aaaa',
   '00000000-0000-0000-0000-0000000131a1', 'SA1'),
  ('00000000-0000-0000-0000-0000000132a2', '00000000-0000-0000-0000-00000013aaaa',
   '00000000-0000-0000-0000-0000000131a1', 'SA2'),
  ('00000000-0000-0000-0000-0000000132b1', '00000000-0000-0000-0000-00000013bbbb',
   '00000000-0000-0000-0000-0000000131b1', 'SB');
insert into public.invitations (id, operator_id, phone, student_id, relationship, role, invited_by) values
  ('00000000-0000-0000-0000-0000000133a1', '00000000-0000-0000-0000-00000013aaaa', '50654000010',
   '00000000-0000-0000-0000-0000000132a1', 'mother', null, '00000000-0000-0000-0000-0000000013a1'),
  ('00000000-0000-0000-0000-0000000133a2', '00000000-0000-0000-0000-00000013aaaa', '50654000011',
   null, null, 'driver', '00000000-0000-0000-0000-0000000013a1');

-- estructura y valores por defecto
select has_index('public', 'invitations', 'invitations_operator_id_idx', 'índice por empresa');
select has_trigger('public', 'invitations', 'invitations_set_updated_at', 'updated_at se mantiene por trigger');
select is((select expires_at from public.invitations where id = '00000000-0000-0000-0000-0000000133a1'),
  now() + interval '14 days', 'vence a los 14 días');
select ok((select active and accepted_at is null from public.invitations
  where id = '00000000-0000-0000-0000-0000000133a1'), 'nace activa y pendiente');

-- checks: rol xor estudiante; relación solo con estudiante; teléfono; quién invita
select throws_ok($$insert into public.invitations (operator_id, phone, invited_by) values
  ('00000000-0000-0000-0000-00000013aaaa', '50654000020', '00000000-0000-0000-0000-0000000013a1')$$,
  '23514', null, 'sin rol ni estudiante rechazada');
select throws_ok($$insert into public.invitations (operator_id, phone, role, student_id, relationship, invited_by)
  values ('00000000-0000-0000-0000-00000013aaaa', '50654000020', 'staff', '00000000-0000-0000-0000-0000000132a1',
  'mother', '00000000-0000-0000-0000-0000000013a1')$$, '23514', null, 'rol y estudiante a la vez rechazada');
select throws_ok($$insert into public.invitations (operator_id, phone, role, relationship, invited_by) values
  ('00000000-0000-0000-0000-00000013aaaa', '50654000020', 'driver', 'other',
   '00000000-0000-0000-0000-0000000013a1')$$, '23514', null, 'relación sin estudiante rechazada');
select throws_ok($$insert into public.invitations (operator_id, phone, student_id, invited_by) values
  ('00000000-0000-0000-0000-00000013aaaa', '50654000020', '00000000-0000-0000-0000-0000000132a1',
   '00000000-0000-0000-0000-0000000013a1')$$, '23514', null, 'estudiante sin relación rechazada');
select throws_ok($$insert into public.invitations (operator_id, phone, role, invited_by) values
  ('00000000-0000-0000-0000-00000013aaaa', '+50654000020', 'driver', '00000000-0000-0000-0000-0000000013a1')$$,
  '23514', null, 'teléfono con símbolos rechazado');
select throws_ok($$insert into public.invitations (operator_id, phone, role, invited_by) values
  ('00000000-0000-0000-0000-00000013aaaa', '1234567', 'driver', '00000000-0000-0000-0000-0000000013a1')$$,
  '23514', null, 'teléfono de menos de 8 dígitos rechazado');
select throws_ok($$insert into public.invitations (operator_id, phone, role, invited_by) values
  ('00000000-0000-0000-0000-00000013aaaa', '1234567890123456', 'driver', '00000000-0000-0000-0000-0000000013a1')$$,
  '23514', null, 'teléfono de más de 15 dígitos rechazado');
select throws_ok($$insert into public.invitations (operator_id, phone, role) values
  ('00000000-0000-0000-0000-00000013aaaa', '50654000020', 'driver')$$, '23502', null, 'quién invita es obligatorio');

-- FK compuesta: estudiante de la misma empresa
select throws_ok($$insert into public.invitations (operator_id, phone, student_id, relationship, invited_by) values
  ('00000000-0000-0000-0000-00000013aaaa', '50654000020', '00000000-0000-0000-0000-0000000132b1', 'mother',
   '00000000-0000-0000-0000-0000000013a1')$$, '23503', null, 'invitación con estudiante de otra empresa rechazada');
select throws_ok($$update public.invitations set student_id = '00000000-0000-0000-0000-0000000132b1'
  where id = '00000000-0000-0000-0000-0000000133a1'$$, '23503', null,
  'invitación no se mueve a estudiante de otra empresa');

-- una sola pendiente por destino
select throws_ok($$insert into public.invitations (operator_id, phone, student_id, relationship, invited_by) values
  ('00000000-0000-0000-0000-00000013aaaa', '50654000010', '00000000-0000-0000-0000-0000000132a1', 'father',
   '00000000-0000-0000-0000-0000000013a1')$$, '23505', null, 'invitación de estudiante pendiente duplicada rechazada');
select throws_ok($$insert into public.invitations (operator_id, phone, role, invited_by) values
  ('00000000-0000-0000-0000-00000013aaaa', '50654000011', 'driver', '00000000-0000-0000-0000-0000000013a1')$$,
  '23505', null, 'invitación de rol pendiente duplicada rechazada');
select lives_ok($$insert into public.invitations (operator_id, phone, student_id, relationship, invited_by) values
  ('00000000-0000-0000-0000-00000013aaaa', '50654000010', '00000000-0000-0000-0000-0000000132a2', 'mother',
   '00000000-0000-0000-0000-0000000013a1')$$, 'mismo teléfono para otro estudiante permitido');
update public.invitations set active = false where id = '00000000-0000-0000-0000-0000000133a1';
select lives_ok($$insert into public.invitations (id, operator_id, phone, student_id, relationship, invited_by)
  values ('00000000-0000-0000-0000-0000000133a3', '00000000-0000-0000-0000-00000013aaaa', '50654000010',
  '00000000-0000-0000-0000-0000000132a1', 'mother', '00000000-0000-0000-0000-0000000013a1')$$,
  'nueva invitación permitida si la anterior está inactiva');
update public.invitations set accepted_at = now() where id = '00000000-0000-0000-0000-0000000133a3';
select lives_ok($$insert into public.invitations (operator_id, phone, student_id, relationship, invited_by) values
  ('00000000-0000-0000-0000-00000013aaaa', '50654000010', '00000000-0000-0000-0000-0000000132a1', 'mother',
   '00000000-0000-0000-0000-0000000013a1')$$, 'nueva invitación permitida si la anterior fue aceptada');
select lives_ok($$insert into public.invitations (operator_id, phone, role, invited_by) values
  ('00000000-0000-0000-0000-00000013bbbb', '50654000011', 'driver', '00000000-0000-0000-0000-0000000013b1')$$,
  'mismo destino en otra empresa permitido');

select * from finish();
rollback;
