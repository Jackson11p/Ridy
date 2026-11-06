-- ATDE-8-T02: empresas (operators) y vínculo persona-empresa con rol (memberships).
create type public.membership_role as enum ('owner', 'driver', 'staff');

create table public.operators (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) > 0),
  country char(2) not null check (country ~ '^[A-Z]{2}$'),
  currency char(3) not null check (currency ~ '^[A-Z]{3}$'),
  timezone text not null,
  plan text not null default 'beta',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.operators enable row level security;

create table public.memberships (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles (id) on delete cascade,
  operator_id uuid not null references public.operators (id),
  role public.membership_role not null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (profile_id, operator_id, role)
);
alter table public.memberships enable row level security;
create index memberships_operator_id_idx on public.memberships (operator_id);

create trigger operators_set_updated_at
  before update on public.operators
  for each row execute function private.set_updated_at();
create trigger memberships_set_updated_at
  before update on public.memberships
  for each row execute function private.set_updated_at();

-- security definer: consulta memberships sin pasar por su RLS (evita recursión).
create function private.has_role(op uuid, roles public.membership_role[])
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.memberships m
    where m.operator_id = op
      and m.profile_id = (select auth.uid())
      and m.active
      and m.role = any (roles)
  );
$$;
revoke execute on function private.has_role(uuid, public.membership_role[]) from public, anon;
grant usage on schema private to authenticated;
grant execute on function private.has_role(uuid, public.membership_role[]) to authenticated;

-- Clientes: sin insert/delete; empresa la crea create_operator; memberships solo lectura.
revoke all on public.operators, public.memberships from anon, authenticated;
grant select on public.operators, public.memberships to authenticated;
grant update (name, country, currency, timezone) on public.operators to authenticated;

create policy "miembro ve su empresa" on public.operators
  for select to authenticated
  using (private.has_role(id, '{owner,driver,staff}'));
create policy "owner edita su empresa" on public.operators
  for update to authenticated
  using (private.has_role(id, '{owner}')) with check (private.has_role(id, '{owner}'));

create policy "persona ve sus memberships; owner/staff las de su empresa" on public.memberships
  for select to authenticated
  using (profile_id = (select auth.uid()) or private.has_role(operator_id, '{owner,staff}'));

create policy "owner/staff ven perfiles de sus miembros" on public.profiles
  for select to authenticated
  using (exists (
    select 1 from public.memberships m
    where m.profile_id = profiles.id and private.has_role(m.operator_id, '{owner,staff}')
  ));
