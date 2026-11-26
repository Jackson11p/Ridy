-- ATDE-39 adversariales: token push solo por set_push_token, sin lectura ni efectos sobre perfiles ajenos.
-- A y B activos; I inactivo; G = sub sin perfil.
begin;
create extension if not exists pgtap with schema extensions;
select plan(23);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000039b1', '50639100001'),
  ('00000000-0000-0000-0000-0000000039b2', '50639100002'),
  ('00000000-0000-0000-0000-0000000039b3', '50639100003');
update public.profiles set active = false where id = '00000000-0000-0000-0000-0000000039b3';
update public.profiles set push_token = 'ExpoPushToken[b2]' where id = '00000000-0000-0000-0000-0000000039b2';
update public.profiles set push_token = 'ExpoPushToken[i3]' where id = '00000000-0000-0000-0000-0000000039b3';

create function pg_temp.token_of(p uuid) returns text language sql as
  $$select push_token from public.profiles where id = p$$;

-- permisos de la función
select ok(not has_function_privilege('anon', 'public.set_push_token(text)', 'execute'), 'anon sin execute');
set local role anon;
select throws_ok($$select public.set_push_token()$$, '42501', null, 'anon no borra tokens sin argumento');
reset role;

set local role authenticated;
set local request.jwt.claims = '{"role":"authenticated"}';
select throws_ok($$select public.set_push_token()$$, '28000', null, 'sin usuario no borra tokens');
reset role;

-- A: oráculos de lectura y escrituras directas
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000039b1","role":"authenticated"}';
select throws_ok($$select count(*) from public.profiles where push_token is not null$$,
  '42501', null, 'filtrar por push_token no sirve de oráculo');
select throws_ok($$select id from public.profiles where push_token = 'ExpoPushToken[b2]'$$,
  '42501', null, 'buscar dueño de un token prohibido');
select throws_ok($$update public.profiles set full_name = 'x', push_token = 'ExpoPushToken[d]'
  where id = '00000000-0000-0000-0000-0000000039b1'$$, '42501', null, 'update mixto con push_token prohibido');
select throws_ok($$insert into public.profiles (id, push_token)
  values ('00000000-0000-0000-0000-0000000039b9', 'ExpoPushToken[n]')$$, '42501', null, 'insert con push_token prohibido');
select lives_ok($$update public.profiles set full_name = 'Ana' where id = '00000000-0000-0000-0000-0000000039b1'$$,
  'update de otras columnas sigue permitido');
-- null solo borra el propio
select lives_ok($$select public.set_push_token(null)$$, 'A borra (no tenía token)');
reset role;
select is(pg_temp.token_of('00000000-0000-0000-0000-0000000039b2'), 'ExpoPushToken[b2]', 'borrar el propio no toca el de B');

-- formatos límite (paridad con expoPushTokenSchema)
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000039b1","role":"authenticated"}';
select lives_ok($$select public.set_push_token('ExpoPushToken[' || repeat('x', 240) || ']')$$, 'token de 255 exacto se acepta');
select throws_ok($$select public.set_push_token('ExpoPushToken[' || repeat('x', 241) || ']')$$, '23514', null, 'token de 256 se rechaza');
select throws_ok($$select public.set_push_token('ExpoPushToken[]')$$, '23514', null, 'corchetes vacíos se rechazan');
select throws_ok($$select public.set_push_token(' ExpoPushToken[a]')$$, '23514', null, 'espacio inicial se rechaza');
select throws_ok($$select public.set_push_token(E'ExpoPushToken[a]\n')$$, '23514', null, 'salto de línea final se rechaza');
select throws_ok($$select public.set_push_token('ExpoPushToken[a]b]')$$, '23514', null, 'texto tras el corchete se rechaza');
select throws_ok($$select public.set_push_token('expopushtoken[a]')$$, '23514', null, 'minúsculas se rechazan');
select throws_ok($$select public.set_push_token('')$$, '23514', null, 'vacío se rechaza');
-- mismo token dos veces: idempotente
select public.set_push_token('ExpoPushToken[same]');
select lives_ok($$select public.set_push_token('ExpoPushToken[same]')$$, 're-registrar el mismo token no choca');
-- A toma el token de un perfil inactivo (mismo teléfono): sale del inactivo
select public.set_push_token('ExpoPushToken[i3]');
reset role;
select results_eq($$select pg_temp.token_of('00000000-0000-0000-0000-0000000039b1'),
  pg_temp.token_of('00000000-0000-0000-0000-0000000039b3')$$,
  $$values ('ExpoPushToken[i3]'::text, null::text)$$, 'traspaso desde perfil inactivo');

-- I inactivo intenta robar el token de B: rechazado y sin efecto lateral
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000039b3","role":"authenticated"}';
select throws_ok($$select public.set_push_token('ExpoPushToken[b2]')$$, '42501', null, 'inactivo no se apropia de un token');
reset role;
select is(pg_temp.token_of('00000000-0000-0000-0000-0000000039b2'), 'ExpoPushToken[b2]', 'B conserva su token tras el intento');

-- G: sub sin perfil no guarda
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000039bf","role":"authenticated"}';
select throws_ok($$select public.set_push_token('ExpoPushToken[b2]')$$, '42501', null, 'sub sin perfil no guarda ni roba');
reset role;

select * from finish();
rollback;
