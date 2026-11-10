-- ATDE-10-T01: estudiantes (students) con colegio de la misma empresa. Sin fotos ni datos sensibles (Ley 8968).
create table public.students (
  id uuid primary key default gen_random_uuid(),
  operator_id uuid not null references public.operators (id),
  school_id uuid not null,
  full_name text not null check (length(trim(full_name)) > 0),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, operator_id),
  foreign key (school_id, operator_id) references public.schools (id, operator_id)
);
alter table public.students enable row level security;
create index students_operator_id_idx on public.students (operator_id);
create index students_school_id_idx on public.students (school_id);

create trigger students_set_updated_at
  before update on public.students
  for each row execute function private.set_updated_at();

-- Clientes: sin delete; update nunca toca id, operator_id ni fechas.
revoke all on public.students from anon, authenticated;
grant select on public.students to authenticated;
grant insert (operator_id, school_id, full_name, active) on public.students to authenticated;
grant update (school_id, full_name, active) on public.students to authenticated;

create policy "owner/staff ven estudiantes de su empresa" on public.students
  for select to authenticated
  using (private.has_role(operator_id, '{owner,staff}'));
create policy "owner/staff crean estudiantes en su empresa" on public.students
  for insert to authenticated
  with check (private.has_role(operator_id, '{owner,staff}'));
create policy "owner/staff editan estudiantes de su empresa" on public.students
  for update to authenticated
  using (private.has_role(operator_id, '{owner,staff}'))
  with check (private.has_role(operator_id, '{owner,staff}'));
