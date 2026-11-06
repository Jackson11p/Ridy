-- ATDE-8-T06: owner/staff solo ven perfiles de memberships activas; push_token no se lee desde clientes.
drop policy "owner/staff ven perfiles de sus miembros" on public.profiles;
create policy "owner/staff ven perfiles de sus miembros" on public.profiles
  for select to authenticated
  using (exists (
    select 1 from public.memberships m
    where m.profile_id = profiles.id
      and m.active
      and private.has_role(m.operator_id, '{owner,staff}')
  ));

revoke select on public.profiles from authenticated;
grant select (id, full_name, phone, locale, active, created_at, updated_at)
  on public.profiles to authenticated;
