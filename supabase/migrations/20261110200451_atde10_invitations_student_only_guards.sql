-- ATDE-10-T05: owner/staff solo tocan invitaciones de estudiante (las de rol, ATDE-17) e invitan solo
-- a encargados de estudiantes activos.
drop policy "owner/staff invitan encargados en su empresa" on public.invitations;
create policy "owner/staff invitan encargados en su empresa" on public.invitations
  for insert to authenticated
  with check (
    role is null
    and invited_by = (select auth.uid())
    and private.has_role(operator_id, '{owner,staff}')
    and exists (
      select 1 from public.students s
      where s.id = invitations.student_id
        and s.active
    )
  );

drop policy "owner/staff (des)activan invitaciones de su empresa" on public.invitations;
create policy "owner/staff (des)activan invitaciones de su empresa" on public.invitations
  for update to authenticated
  using (role is null and private.has_role(operator_id, '{owner,staff}'))
  with check (role is null and private.has_role(operator_id, '{owner,staff}'));
