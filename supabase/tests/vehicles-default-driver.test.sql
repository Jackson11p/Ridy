-- ATDE-9-T05/T06: chofer habitual validado para clientes autenticados; solo si el valor cambia.
-- Empresa A: O owner, S staff, D y D2 drivers, Z staff (no driver).
begin;
create extension if not exists pgtap with schema extensions;
select plan(9);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000005a1', '50630000011'),  -- O
  ('00000000-0000-0000-0000-0000000005a2', '50630000012'),  -- S
  ('00000000-0000-0000-0000-0000000005a3', '50630000013'),  -- D
  ('00000000-0000-0000-0000-0000000005a4', '50630000014'),  -- D2
  ('00000000-0000-0000-0000-0000000005a5', '50630000015');  -- Z
insert into public.operators (id, name, country, currency, timezone) values
  ('00000000-0000-0000-0000-00000005aaaa', 'Busetas A', 'CR', 'CRC', 'America/Costa_Rica');
insert into public.memberships (profile_id, operator_id, role)
select ('00000000-0000-0000-0000-0000000005' || p)::uuid, '00000000-0000-0000-0000-00000005aaaa', r::public.membership_role
from (values ('a1', 'owner'), ('a2', 'staff'), ('a3', 'driver'), ('a4', 'driver'), ('a5', 'staff')) as m (p, r);
insert into public.vehicles (id, operator_id, plate, capacity, default_driver_id) values
  ('00000000-0000-0000-0000-0000000051a1', '00000000-0000-0000-0000-00000005aaaa', 'V1', 20,
   '00000000-0000-0000-0000-0000000005a3');

-- S: staff cambia el chofer habitual
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000005a2","role":"authenticated"}';
select lives_ok($$update public.vehicles set default_driver_id = '00000000-0000-0000-0000-0000000005a4'
  where id = '00000000-0000-0000-0000-0000000051a1'$$, 'staff cambia el chofer habitual a un driver válido');
reset role;
select is((select default_driver_id from public.vehicles where id = '00000000-0000-0000-0000-0000000051a1'),
  '00000000-0000-0000-0000-0000000005a4'::uuid, 'cambio de chofer habitual persistido');

-- O: owner autenticado choca con el trigger
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000005a1","role":"authenticated"}';
select throws_ok($$update public.vehicles set default_driver_id = '00000000-0000-0000-0000-0000000005a5'
  where id = '00000000-0000-0000-0000-0000000051a1'$$, '23514', null, 'owner no asigna chofer sin rol driver');
select throws_ok($$insert into public.vehicles (operator_id, plate, capacity, default_driver_id)
  values ('00000000-0000-0000-0000-00000005aaaa', 'V2', 10, '00000000-0000-0000-0000-0000000005a5')$$,
  '23514', null, 'owner no crea buseta con chofer sin rol driver');
select lives_ok($$insert into public.vehicles (operator_id, plate, capacity, default_driver_id)
  values ('00000000-0000-0000-0000-00000005aaaa', 'V3', 10, '00000000-0000-0000-0000-0000000005a3')$$,
  'owner crea buseta con chofer válido');
reset role;

-- T06: solo valida si el chofer cambia; exige perfil activo
update public.memberships set active = false where profile_id = '00000000-0000-0000-0000-0000000005a4';
update public.profiles set active = false where id = '00000000-0000-0000-0000-0000000005a3';
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000005a1","role":"authenticated"}';
select lives_ok($$update public.vehicles set plate = 'V1', capacity = 22, active = true,
  default_driver_id = '00000000-0000-0000-0000-0000000005a4'
  where id = '00000000-0000-0000-0000-0000000051a1'$$, 'update con fila completa sin cambiar chofer ya inactivo');
select throws_ok($$insert into public.vehicles (operator_id, plate, capacity, default_driver_id)
  values ('00000000-0000-0000-0000-00000005aaaa', 'V4', 10, '00000000-0000-0000-0000-0000000005a3')$$,
  '23514', null, 'chofer con perfil inactivo rechazado al crear');
select throws_ok($$update public.vehicles set default_driver_id = '00000000-0000-0000-0000-0000000005a3'
  where id = '00000000-0000-0000-0000-0000000051a1'$$, '23514', null, 'chofer con perfil inactivo rechazado al cambiar');
reset role;
select has_index('public', 'vehicles', 'vehicles_default_driver_id_idx', 'índice por chofer habitual');

select * from finish();
rollback;
