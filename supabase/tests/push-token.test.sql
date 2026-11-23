-- ATDE-39-T01: el token push solo se escribe por set_push_token; un teléfono = un dueño del token.
-- A y B activos; I inactivo.
begin;
create extension if not exists pgtap with schema extensions;
select plan(15);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000039a1', '50639000001'),
  ('00000000-0000-0000-0000-0000000039a2', '50639000002'),
  ('00000000-0000-0000-0000-0000000039a3', '50639000003');
update public.profiles set active = false where id = '00000000-0000-0000-0000-0000000039a3';

create function pg_temp.token_of(p uuid) returns text language sql as
  $$select push_token from public.profiles where id = p$$;

select ok((select prosecdef and proconfig @> array['search_path=""'] from pg_proc
  where oid = 'public.set_push_token(text)'::regprocedure),
  'set_push_token es security definer con search_path vacío');

set local role anon;
select throws_ok($$select public.set_push_token('ExpoPushToken[x]')$$, '42501', null, 'anon no guarda tokens');
reset role;

set local role authenticated;
set local request.jwt.claims = '{"role":"authenticated"}';
select throws_ok($$select public.set_push_token('ExpoPushToken[x]')$$, '28000', null, 'sin usuario no guarda tokens');
reset role;

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000039a3","role":"authenticated"}';
select throws_ok($$select public.set_push_token('ExpoPushToken[i]')$$, '42501', null, 'perfil inactivo no guarda token');
reset role;

-- A guarda, cambia y prueba formatos
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000039a1","role":"authenticated"}';
select lives_ok($$select public.set_push_token('ExpoPushToken[aaa]')$$, 'A guarda su token');
select lives_ok($$select public.set_push_token('ExponentPushToken[bbb]')$$, 'A cambia su token');
select throws_ok($$select public.set_push_token('tok')$$, '23514', null, 'formato inválido se rechaza');
select throws_ok($$select public.set_push_token('ExpoPushToken[' || repeat('x', 300) || ']')$$,
  '23514', null, 'token de más de 255 se rechaza');
select throws_ok($$update public.profiles set push_token = 'ExpoPushToken[d]'
  where id = '00000000-0000-0000-0000-0000000039a1'$$, '42501', null, 'update directo de push_token prohibido');
select throws_ok($$select push_token from public.profiles where id = '00000000-0000-0000-0000-0000000039a1'$$,
  '42501', null, 'push_token propio no se lee');
select throws_ok($$select push_token from public.profiles where id = '00000000-0000-0000-0000-0000000039a2'$$,
  '42501', null, 'push_token ajeno no se lee');
reset role;
select is(pg_temp.token_of('00000000-0000-0000-0000-0000000039a1'), 'ExponentPushToken[bbb]', 'token de A cambiado');

-- B inicia sesión en el teléfono de A: el token pasa a B
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000039a2","role":"authenticated"}';
select public.set_push_token('ExponentPushToken[bbb]');
reset role;
select results_eq($$select pg_temp.token_of('00000000-0000-0000-0000-0000000039a1'),
  pg_temp.token_of('00000000-0000-0000-0000-0000000039a2')$$,
  $$values (null::text, 'ExponentPushToken[bbb]'::text)$$, 'traspaso: el token deja el perfil de A y queda en B');

-- B cierra sesión: null borra
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000039a2","role":"authenticated"}';
select lives_ok($$select public.set_push_token(null)$$, 'B borra su token');
reset role;
select is(pg_temp.token_of('00000000-0000-0000-0000-0000000039a2'), null, 'token de B borrado');

select * from finish();
rollback;
