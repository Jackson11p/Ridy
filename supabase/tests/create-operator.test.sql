-- ATDE-8-T03: create_operator crea empresa + membership owner en un paso.
begin;
create extension if not exists pgtap with schema extensions;
select plan(9);

insert into auth.users (id, phone) values ('00000000-0000-0000-0000-0000000000c1', '50660000001');

select ok((select prosecdef and proconfig @> array['search_path=""'] from pg_proc
  where oid = 'public.create_operator(text, text, text, text)'::regprocedure),
  'create_operator es security definer con search_path vacío');

-- anon no puede llamarla
set local role anon;
select throws_ok($$select public.create_operator('x', 'CR', 'CRC', 'UTC')$$,
  '42501', null, 'anon no crea empresas');
reset role;

-- authenticated sin usuario
set local role authenticated;
set local request.jwt.claims = '{"role":"authenticated"}';
select throws_ok($$select public.create_operator('x', 'CR', 'CRC', 'UTC')$$,
  '28000', null, 'sin usuario no crea empresas');
reset role;

-- usuario C crea su empresa
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}';
select isnt(public.create_operator('Busetas C', 'CR', 'CRC', 'America/Costa_Rica'), null,
  'devuelve el id de la empresa');
select is((select name from public.operators), 'Busetas C', 'C ve su empresa nueva');
select is((select count(*) from public.memberships), 1::bigint, 'se crea una membership');
select is((select role from public.memberships), 'owner'::public.membership_role, 'C queda como owner');
select is((select profile_id from public.memberships), '00000000-0000-0000-0000-0000000000c1'::uuid,
  'membership es de quien la crea');
select throws_ok($$select public.create_operator('y', 'cr', 'CRC', 'UTC')$$,
  '23514', null, 'país inválido se rechaza');
reset role;

select * from finish();
rollback;
