-- ATDE-17-T02: owner/staff invitan choferes; el cliente no inserta invitaciones de rol directamente.
create function public.invite_driver(operator_id uuid, phone text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller uuid := (select auth.uid());
  new_id uuid;
begin
  if caller is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;
  if not private.has_role(invite_driver.operator_id, '{owner,staff}') then
    raise exception 'not owner or staff of operator' using errcode = '42501';
  end if;

  -- Una pendiente vencida bloquearía el índice único y el cliente no puede desactivarla.
  update public.invitations i set active = false
  where i.operator_id = invite_driver.operator_id
    and i.phone = invite_driver.phone
    and i.role = 'driver'
    and i.active
    and i.accepted_at is null
    and i.expires_at <= now();

  insert into public.invitations (operator_id, phone, role, invited_by)
  values (invite_driver.operator_id, invite_driver.phone, 'driver', caller)
  returning id into new_id;

  return new_id;
end;
$$;

revoke execute on function public.invite_driver(uuid, text) from public, anon;
grant execute on function public.invite_driver(uuid, text) to authenticated;
