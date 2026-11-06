-- ATDE-8-T01: profiles, alta automática desde auth.users y RLS de perfil propio.
begin;
create extension if not exists pgtap with schema extensions;
select plan(14);

insert into auth.users (id, phone, raw_user_meta_data) values
  ('00000000-0000-0000-0000-00000000000a', '50688880001', '{"full_name":"Ana"}'),
  ('00000000-0000-0000-0000-00000000000b', '50688880002', '{"full_name":"Beto"}');

-- trigger de alta
select is((select count(*) from public.profiles), 2::bigint, 'alta en auth.users crea perfil');
select is((select phone from public.profiles where id = '00000000-0000-0000-0000-00000000000a'),
  '50688880001', 'perfil copia el teléfono');
select is((select full_name from public.profiles where id = '00000000-0000-0000-0000-00000000000a'),
  'Ana', 'perfil copia el nombre');
select is((select locale from public.profiles where id = '00000000-0000-0000-0000-00000000000a'),
  'es', 'idioma por defecto es');
select ok((select active from public.profiles where id = '00000000-0000-0000-0000-00000000000a'),
  'perfil nace activo');

-- anon
set local role anon;
select throws_ok('select 1 from public.profiles', '42501', null, 'anon no ve perfiles');
reset role;

-- usuario A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';
select is((select count(*) from public.profiles), 1::bigint, 'A ve solo su perfil');
select lives_ok($$update public.profiles set full_name = 'Ana M', push_token = 't', locale = 'en'
  where id = '00000000-0000-0000-0000-00000000000a'$$, 'A edita nombre, token e idioma');
select throws_ok($$update public.profiles set phone = '1' where id = '00000000-0000-0000-0000-00000000000a'$$,
  '42501', null, 'A no cambia su teléfono');
select throws_ok($$update public.profiles set active = false where id = '00000000-0000-0000-0000-00000000000a'$$,
  '42501', null, 'A no cambia active');
update public.profiles set full_name = 'hackeado' where id = '00000000-0000-0000-0000-00000000000b';
select throws_ok($$insert into public.profiles (id, phone) values (gen_random_uuid(), '9')$$,
  '42501', null, 'A no inserta perfiles');
select throws_ok($$delete from public.profiles where id = '00000000-0000-0000-0000-00000000000a'$$,
  '42501', null, 'A no borra perfiles');
reset role;

select is((select full_name from public.profiles where id = '00000000-0000-0000-0000-00000000000b'),
  'Beto', 'A no edita el perfil de B');
select is((select full_name from public.profiles where id = '00000000-0000-0000-0000-00000000000a'),
  'Ana M', 'cambio de A persistido');

select * from finish();
rollback;
