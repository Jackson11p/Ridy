-- ATDE-17-T02: invite_driver crea invitación de rol driver; solo owner/staff de esa empresa.
-- Empresa A: O owner, S staff, D driver. Empresa B: B owner. IV invitación vencida en A.
begin;
create extension if not exists pgtap with schema extensions;
select plan(13);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000017a1', '50617000001'),  -- O
  ('00000000-0000-0000-0000-0000000017a2', '50617000002'),  -- S
  ('00000000-0000-0000-0000-0000000017a3', '50617000003'),  -- D
  ('00000000-0000-0000-0000-0000000017b1', '50617000004');  -- B
insert into public.operators (id, name, country, currency, timezone) values
  ('00000000-0000-0000-0000-00000017aaaa', 'Busetas A', 'CR', 'CRC', 'America/Costa_Rica'),
  ('00000000-0000-0000-0000-00000017bbbb', 'Busetas B', 'CR', 'CRC', 'America/Costa_Rica');
insert into public.memberships (profile_id, operator_id, role) values
  ('00000000-0000-0000-0000-0000000017a1', '00000000-0000-0000-0000-00000017aaaa', 'owner'),
  ('00000000-0000-0000-0000-0000000017a2', '00000000-0000-0000-0000-00000017aaaa', 'staff'),
  ('00000000-0000-0000-0000-0000000017a3', '00000000-0000-0000-0000-00000017aaaa', 'driver'),
  ('00000000-0000-0000-0000-0000000017b1', '00000000-0000-0000-0000-00000017bbbb', 'owner');
insert into public.invitations (id, operator_id, phone, role, invited_by, expires_at) values
  ('00000000-0000-0000-0000-0000000173a1', '00000000-0000-0000-0000-00000017aaaa', '50617000050', 'driver',
   '00000000-0000-0000-0000-0000000017a1', now() - interval '1 day');

select ok((select prosecdef and proconfig @> array['search_path=""'] from pg_proc
  where oid = 'public.invite_driver(uuid, text)'::regprocedure),
  'invite_driver es security definer con search_path vacío');

set local role anon;
select throws_ok($$select public.invite_driver('00000000-0000-0000-0000-00000017aaaa', '50617000010')$$,
  '42501', null, 'anon no invita');
reset role;

set local role authenticated;
set local request.jwt.claims = '{"role":"authenticated"}';
select throws_ok($$select public.invite_driver('00000000-0000-0000-0000-00000017aaaa', '50617000010')$$,
  '28000', null, 'sin sesión no invita');
reset role;

-- O: owner invita
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000017a1","role":"authenticated"}';
select isnt(public.invite_driver('00000000-0000-0000-0000-00000017aaaa', '50617000010'), null,
  'owner invita chofer y recibe el id');
select throws_ok($$select public.invite_driver('00000000-0000-0000-0000-00000017aaaa', '50617000010')$$,
  '23505', null, 'invitación vigente duplicada se rechaza');
select throws_ok($$select public.invite_driver('00000000-0000-0000-0000-00000017aaaa', '+506-17')$$,
  '23514', null, 'teléfono inválido se rechaza');
select lives_ok($$select public.invite_driver('00000000-0000-0000-0000-00000017aaaa', '50617000050')$$,
  'vencida no bloquea reinvitar');
reset role;

-- S: staff invita
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000017a2","role":"authenticated"}';
select lives_ok($$select public.invite_driver('00000000-0000-0000-0000-00000017aaaa', '50617000011')$$,
  'staff invita chofer');
reset role;

-- D: chofer no invita
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000017a3","role":"authenticated"}';
select throws_ok($$select public.invite_driver('00000000-0000-0000-0000-00000017aaaa', '50617000012')$$,
  '42501', null, 'chofer no invita');
reset role;

-- B: owner de otra empresa no invita en A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000017b1","role":"authenticated"}';
select throws_ok($$select public.invite_driver('00000000-0000-0000-0000-00000017aaaa', '50617000013')$$,
  '42501', null, 'owner de otra empresa no invita');
reset role;

-- resultados
select results_eq($$select phone, role, invited_by from public.invitations
  where operator_id = '00000000-0000-0000-0000-00000017aaaa' and active order by phone$$,
  $$values ('50617000010', 'driver'::public.membership_role, '00000000-0000-0000-0000-0000000017a1'::uuid),
           ('50617000011', 'driver', '00000000-0000-0000-0000-0000000017a2'),
           ('50617000050', 'driver', '00000000-0000-0000-0000-0000000017a1')$$,
  'solo las invitaciones de owner/staff, rol driver, invitadas por la sesión');
select is((select active from public.invitations where id = '00000000-0000-0000-0000-0000000173a1'), false,
  'la vencida queda desactivada');
select is((select count(*) from public.invitations where phone in ('50617000012', '50617000013')), 0::bigint,
  'rechazadas no dejan filas');

select * from finish();
rollback;
