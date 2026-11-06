-- Ejemplo de prueba RLS (ATDE-7). Copiar este patrón para cada tabla real.
-- Corre con `pnpm test:db` (stack local arriba). Todo se deshace con rollback.
begin;
create extension if not exists pgtap with schema extensions;
select plan(5);

-- Tabla solo para el ejemplo: vive dentro de la transacción, no es esquema.
create table public.rls_ejemplo (
  id int primary key,
  owner_id uuid not null,
  nota text not null
);
grant select on public.rls_ejemplo to anon, authenticated;
alter table public.rls_ejemplo enable row level security;
create policy "dueño ve sus filas" on public.rls_ejemplo
  for select to authenticated using (owner_id = auth.uid());

insert into public.rls_ejemplo values
  (1, '00000000-0000-0000-0000-00000000000a', 'de A'),
  (2, '00000000-0000-0000-0000-00000000000b', 'de B');

-- anon: no ve nada
set local role anon;
select is((select count(*) from public.rls_ejemplo), 0::bigint, 'anon no ve filas');
reset role;

-- usuario A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';
select is((select count(*) from public.rls_ejemplo), 1::bigint, 'A ve una fila');
select is((select nota from public.rls_ejemplo), 'de A', 'A ve solo la suya');
reset role;

-- usuario B
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated"}';
select is((select count(*) from public.rls_ejemplo), 1::bigint, 'B ve una fila');
select is_empty('select 1 from public.rls_ejemplo where id = 1', 'B no ve la de A');
reset role;

select * from finish();
rollback;
