-- ATDE-10-T03: invitaciones por teléfono a un rol o como encargado de un estudiante; la acepta el servidor.
create table public.invitations (
  id uuid primary key default gen_random_uuid(),
  operator_id uuid not null references public.operators (id),
  phone text not null check (phone ~ '^[0-9]{8,15}$'),
  role public.membership_role,
  student_id uuid,
  relationship public.guardian_relationship,
  invited_by uuid not null default auth.uid() references public.profiles (id),
  expires_at timestamptz not null default now() + interval '14 days',
  accepted_at timestamptz,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (num_nonnulls(role, student_id) = 1),
  check ((student_id is null) = (relationship is null)),
  foreign key (student_id, operator_id) references public.students (id, operator_id)
);
alter table public.invitations enable row level security;
create index invitations_operator_id_idx on public.invitations (operator_id);
create index invitations_student_id_idx on public.invitations (student_id);
-- Una sola invitación pendiente por destino (rol o estudiante) y teléfono en cada empresa.
create unique index invitations_pending_idx
  on public.invitations (operator_id, phone, role, student_id) nulls not distinct
  where active and accepted_at is null;

create trigger invitations_set_updated_at
  before update on public.invitations
  for each row execute function private.set_updated_at();

-- Clientes: solo invitaciones de estudiante (las de rol, ATDE-17); quién invita, vencimiento y
-- aceptación los pone la BD o el servidor. Sin delete; update solo (des)activa.
revoke all on public.invitations from anon, authenticated;
grant select on public.invitations to authenticated;
grant insert (operator_id, phone, student_id, relationship) on public.invitations to authenticated;
grant update (active) on public.invitations to authenticated;

create policy "owner/staff ven invitaciones de su empresa" on public.invitations
  for select to authenticated
  using (private.has_role(operator_id, '{owner,staff}'));
create policy "owner/staff invitan encargados en su empresa" on public.invitations
  for insert to authenticated
  with check (
    role is null
    and invited_by = (select auth.uid())
    and private.has_role(operator_id, '{owner,staff}')
  );
create policy "owner/staff (des)activan invitaciones de su empresa" on public.invitations
  for update to authenticated
  using (private.has_role(operator_id, '{owner,staff}'))
  with check (private.has_role(operator_id, '{owner,staff}'));
