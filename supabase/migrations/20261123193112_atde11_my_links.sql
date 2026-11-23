-- ATDE-11-T01: vínculos vigentes de quien llama (roles por empresa e hijos) para que la app elija vista.
-- security definer: el padre necesita el nombre de su transportista y la RLS de operators solo lo muestra a miembros.
-- Sin parámetros y filtrado por auth.uid(): nadie pide los vínculos de otro. Mismo criterio que has_role/is_guardian_of.
create function public.my_links()
returns table (
  kind text, operator_id uuid, operator_name text,
  role public.membership_role, student_id uuid, student_name text
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  caller uuid := (select auth.uid());
begin
  if caller is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;

  return query
  select l.kind, l.operator_id, l.operator_name, l.role, l.student_id, l.student_name
  from (
    select 'membership'::text as kind, o.id as operator_id, o.name as operator_name,
      m.role, null::uuid as student_id, null::text as student_name
    from public.memberships m
    join public.operators o on o.id = m.operator_id
    where m.profile_id = caller and m.active
    union all
    select 'guardian', o.id, o.name, null, s.id, s.full_name
    from public.guardians g
    join public.students s on s.id = g.student_id
    join public.operators o on o.id = g.operator_id
    where g.profile_id = caller and g.active and s.active
  ) as l
  where exists (select 1 from public.profiles p where p.id = caller and p.active)
  order by l.kind, l.operator_name, l.role, l.student_name;
end;
$$;
revoke execute on function public.my_links() from public, anon;
grant execute on function public.my_links() to authenticated;
