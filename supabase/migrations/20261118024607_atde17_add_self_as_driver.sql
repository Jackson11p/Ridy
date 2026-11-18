-- ATDE-17-T03: el owner que maneja se marca chofer de su empresa; conserva su rol owner.
create function public.add_self_as_driver(operator_id uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller uuid := (select auth.uid());
  membership_id uuid;
begin
  if caller is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;
  if not private.has_role(add_self_as_driver.operator_id, '{owner}') then
    raise exception 'not owner of operator' using errcode = '42501';
  end if;

  insert into public.memberships (profile_id, operator_id, role)
  values (caller, add_self_as_driver.operator_id, 'driver')
  on conflict on constraint memberships_profile_id_operator_id_role_key
    do update set active = true
  returning id into membership_id;

  return membership_id;
end;
$$;

revoke execute on function public.add_self_as_driver(uuid) from public, anon;
grant execute on function public.add_self_as_driver(uuid) to authenticated;
