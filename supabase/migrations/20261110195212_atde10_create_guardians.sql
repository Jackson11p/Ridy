-- ATDE-10-T02: vínculo encargado-estudiante (guardians). Lo crea el servidor (accept-invite), nunca el cliente.
create type public.guardian_relationship as enum ('mother', 'father', 'grandparent', 'legal_guardian', 'other');

create table public.guardians (
  id uuid primary key default gen_random_uuid(),
  operator_id uuid not null references public.operators (id),
  student_id uuid not null,
  profile_id uuid not null references public.profiles (id),
  relationship public.guardian_relationship not null,
  receives_notifications boolean not null default true,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (student_id, profile_id),
  foreign key (student_id, operator_id) references public.students (id, operator_id)
);
alter table public.guardians enable row level security;
create index guardians_operator_id_idx on public.guardians (operator_id);
create index guardians_profile_id_idx on public.guardians (profile_id);

create trigger guardians_set_updated_at
  before update on public.guardians
  for each row execute function private.set_updated_at();

-- Los grants de update son por rol: "recibe avisos" solo lo cambia el propio encargado.
create function private.guard_guardian_notifications()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if current_user = 'authenticated' and old.profile_id is distinct from (select auth.uid()) then
    raise exception 'only the guardian changes receives_notifications' using errcode = '42501';
  end if;
  return new;
end;
$$;
revoke execute on function private.guard_guardian_notifications() from public;

create trigger guardians_guard_notifications
  before update on public.guardians
  for each row
  when (old.receives_notifications is distinct from new.receives_notifications)
  execute function private.guard_guardian_notifications();

-- security definer: lee guardians y profiles sin su RLS (evita recursión students <-> guardians).
create function private.is_guardian_of(student uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.guardians g
    join public.profiles p on p.id = g.profile_id
    where g.student_id = student
      and g.profile_id = (select auth.uid())
      and g.active
      and p.active
  );
$$;
revoke execute on function private.is_guardian_of(uuid) from public, anon;
grant execute on function private.is_guardian_of(uuid) to authenticated;

-- Clientes: sin insert ni delete; owner/staff (des)activan, el padre cambia sus avisos.
revoke all on public.guardians from anon, authenticated;
grant select on public.guardians to authenticated;
grant update (active, receives_notifications) on public.guardians to authenticated;

create policy "owner/staff ven vínculos de su empresa" on public.guardians
  for select to authenticated
  using (private.has_role(operator_id, '{owner,staff}'));
create policy "owner/staff editan vínculos de su empresa" on public.guardians
  for update to authenticated
  using (private.has_role(operator_id, '{owner,staff}'))
  with check (private.has_role(operator_id, '{owner,staff}'));
create policy "padre ve su vínculo activo" on public.guardians
  for select to authenticated
  using (profile_id = (select auth.uid()) and private.is_guardian_of(student_id));
-- with check exige active: el padre no se desactiva (el using solo ve filas activas).
create policy "padre edita su vínculo activo" on public.guardians
  for update to authenticated
  using (profile_id = (select auth.uid()) and private.is_guardian_of(student_id))
  with check (profile_id = (select auth.uid()) and active);

create policy "padre ve a sus hijos activos" on public.students
  for select to authenticated
  using (active and private.is_guardian_of(id));

create policy "owner/staff ven perfiles de encargados de su empresa" on public.profiles
  for select to authenticated
  using (exists (
    select 1 from public.guardians g
    where g.profile_id = profiles.id
      and g.active
      and private.has_role(g.operator_id, '{owner,staff}')
  ));
