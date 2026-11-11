-- ATDE-10-T06: estudiante inactivo: el padre no ve ni edita al niño ni su vínculo.
-- security definer: lee guardians, profiles y students sin su RLS (evita recursión students <-> guardians).
create or replace function private.is_guardian_of(student uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.guardians g
    join public.profiles p on p.id = g.profile_id
    join public.students s on s.id = g.student_id
    where g.student_id = student
      and g.profile_id = (select auth.uid())
      and g.active
      and p.active
      and s.active
  );
$$;
