-- ATDE-8-T06: perfiles de miembros solo con membership activa; push_token nunca se lee.
-- Empresa A: O owner, M1 driver activo, M2 driver inactivo.
begin;
create extension if not exists pgtap with schema extensions;
select plan(7);

insert into auth.users (id, phone, raw_user_meta_data) values
  ('00000000-0000-0000-0000-0000000000d1', '50650000001', '{"full_name":"O"}'),
  ('00000000-0000-0000-0000-0000000000d2', '50650000002', '{"full_name":"M1"}'),
  ('00000000-0000-0000-0000-0000000000d3', '50650000003', '{"full_name":"M2"}');
insert into public.operators (id, name, country, currency, timezone) values
  ('00000000-0000-0000-0000-00000000dddd', 'Busetas D', 'CR', 'CRC', 'America/Costa_Rica');
insert into public.memberships (profile_id, operator_id, role, active) values
  ('00000000-0000-0000-0000-0000000000d1', '00000000-0000-0000-0000-00000000dddd', 'owner', true),
  ('00000000-0000-0000-0000-0000000000d2', '00000000-0000-0000-0000-00000000dddd', 'driver', true),
  ('00000000-0000-0000-0000-0000000000d3', '00000000-0000-0000-0000-00000000dddd', 'driver', false);

-- O: owner
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000d1","role":"authenticated"}';
select is((select count(*) from public.profiles), 2::bigint, 'owner ve su perfil y el del miembro activo');
select is_empty($$select 1 from public.profiles where id = '00000000-0000-0000-0000-0000000000d3'$$,
  'owner no ve perfil con membership inactiva');
select is((select phone from public.profiles where id = '00000000-0000-0000-0000-0000000000d2'),
  '50650000002', 'owner ve el teléfono de su chofer');
select throws_ok($$select push_token from public.profiles where id = '00000000-0000-0000-0000-0000000000d1'$$,
  '42501', null, 'push_token propio no se lee');
select throws_ok($$select push_token from public.profiles where id = '00000000-0000-0000-0000-0000000000d2'$$,
  '42501', null, 'push_token ajeno no se lee');
reset role;

-- M1: actualiza su token
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000d2","role":"authenticated"}';
select lives_ok($$update public.profiles set push_token = 'tok'
  where id = '00000000-0000-0000-0000-0000000000d2'$$, 'usuario sigue actualizando su push_token');
reset role;

select is((select push_token from public.profiles where id = '00000000-0000-0000-0000-0000000000d2'),
  'tok', 'push_token persistido');

select * from finish();
rollback;
