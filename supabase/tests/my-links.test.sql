-- ATDE-11-T01: my_links devuelve solo los vínculos vigentes de auth.uid() (reglas 1–5 de "Cuentas y roles").
-- Empresa A: G1 encargado de S1, S2 y S3 (inactivo); D1 chofer; O1 owner + chofer; M1 chofer + encargado de S4;
-- N1 sin vínculos; I1 perfil inactivo con vínculos; X1 membresía y vínculo inactivos. Empresa B: B1 owner.
begin;
create extension if not exists pgtap with schema extensions;
select plan(12);

insert into auth.users (id, phone)
select ('00000000-0000-0000-0000-0000000011a' || n)::uuid, '5065400000' || n
from generate_series(1, 8) as n;
update public.profiles set active = false where id = '00000000-0000-0000-0000-0000000011a6';
insert into public.operators (id, name, country, currency, timezone) values
  ('00000000-0000-0000-0000-00000011aaaa', 'Busetas A', 'CR', 'CRC', 'America/Costa_Rica'),
  ('00000000-0000-0000-0000-00000011bbbb', 'Busetas B', 'CR', 'CRC', 'America/Costa_Rica');
insert into public.schools (id, operator_id, name, location) values
  ('00000000-0000-0000-0000-0000001111a1', '00000000-0000-0000-0000-00000011aaaa', 'Colegio',
   extensions.st_setsrid(extensions.st_makepoint(-84.09, 9.93), 4326)::extensions.geography);
insert into public.students (id, operator_id, school_id, full_name, active)
select ('00000000-0000-0000-0000-0000001112a' || n)::uuid, '00000000-0000-0000-0000-00000011aaaa',
  '00000000-0000-0000-0000-0000001111a1', name, n <> 3
from (values (1, 'Ana'), (2, 'Beto'), (3, 'Caro'), (4, 'Dani'), (5, 'Eva')) as s (n, name);
insert into public.guardians (operator_id, student_id, profile_id, relationship, active)
select '00000000-0000-0000-0000-00000011aaaa', ('00000000-0000-0000-0000-0000001112a' || s)::uuid,
  ('00000000-0000-0000-0000-0000000011a' || p)::uuid, 'mother', a
from (values (1, 1, true), (2, 1, true), (3, 1, true), (4, 4, true), (1, 6, true), (5, 7, false)) as g (s, p, a);
insert into public.memberships (profile_id, operator_id, role, active)
select ('00000000-0000-0000-0000-0000000011a' || p)::uuid, ('00000000-0000-0000-0000-00000011' || o)::uuid,
  r::public.membership_role, a
from (values (2, 'aaaa', 'driver', true), (3, 'aaaa', 'owner', true), (3, 'aaaa', 'driver', true),
  (4, 'aaaa', 'driver', true), (6, 'aaaa', 'driver', true), (7, 'aaaa', 'staff', false),
  (8, 'bbbb', 'owner', true)) as m (p, o, r, a);

select ok((select prosecdef and proconfig @> array['search_path=""'] and pronargs = 0 from pg_proc
  where oid = 'public.my_links()'::regprocedure),
  'my_links es security definer, search_path vacío y sin parámetros (no se piden vínculos de otro)');

set local role anon;
select throws_ok('select * from public.my_links()', '42501', null, 'anon no consulta vínculos');
reset role;

set local role authenticated;
set local request.jwt.claims = '{"role":"authenticated"}';
select throws_ok('select * from public.my_links()', '28000', null, 'sin usuario no consulta vínculos');
reset role;

-- Caso 1: solo encargado (hijo inactivo no aparece)
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000011a1","role":"authenticated"}';
select results_eq('select kind, operator_name, role::text, student_name from public.my_links()',
  $$values ('guardian', 'Busetas A', null, 'Ana'), ('guardian', 'Busetas A', null, 'Beto')$$,
  'solo encargado: sus hijos activos, sin roles');
select results_eq('select operator_id, student_id from public.my_links()',
  $$values ('00000000-0000-0000-0000-00000011aaaa'::uuid, '00000000-0000-0000-0000-0000001112a1'::uuid),
           ('00000000-0000-0000-0000-00000011aaaa'::uuid, '00000000-0000-0000-0000-0000001112a2'::uuid)$$,
  'solo encargado: ids de empresa e hijos');
reset role;

-- Caso 2: solo chofer
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000011a2","role":"authenticated"}';
select results_eq('select kind, operator_name, role::text, student_id from public.my_links()',
  $$values ('membership', 'Busetas A', 'driver', null::uuid)$$, 'solo chofer: un rol, sin hijos');
reset role;

-- Caso 3: dueño que maneja
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000011a3","role":"authenticated"}';
select results_eq('select kind, operator_name, role::text from public.my_links()',
  $$values ('membership', 'Busetas A', 'owner'), ('membership', 'Busetas A', 'driver')$$,
  'dueño: owner y driver en su empresa');
reset role;

-- Caso 4: varios roles (chofer que también es padre)
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000011a4","role":"authenticated"}';
select results_eq('select kind, role::text, student_name from public.my_links()',
  $$values ('guardian', null, 'Dani'), ('membership', 'driver', null)$$, 'varios roles: hijo y rol de chofer');
reset role;

-- Caso 5: sin vínculos
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000011a5","role":"authenticated"}';
select is_empty('select * from public.my_links()', 'sin vínculos: resultado vacío');
reset role;

-- Perfil inactivo y vínculos inactivos no cuentan
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000011a6","role":"authenticated"}';
select is_empty('select * from public.my_links()', 'perfil inactivo: sin vínculos');
reset role;
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000011a7","role":"authenticated"}';
select is_empty('select * from public.my_links()', 'membresía y vínculo inactivos: sin vínculos');
reset role;

-- Otra empresa: solo lo suyo, nada de A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000011a8","role":"authenticated"}';
select results_eq('select kind, operator_id, role::text from public.my_links()',
  $$values ('membership', '00000000-0000-0000-0000-00000011bbbb'::uuid, 'owner')$$,
  'owner de B: solo su rol en B, nada de A');
reset role;

select * from finish();
rollback;
