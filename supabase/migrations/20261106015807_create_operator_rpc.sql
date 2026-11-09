-- ATDE-8-T03: crear empresa + membership owner de quien la crea, en un paso.
create function public.create_operator(
  name text, country text, currency text, timezone text
)
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

  insert into public.operators (name, country, currency, timezone)
  values (create_operator.name, create_operator.country, create_operator.currency, create_operator.timezone)
  returning id into new_id;

  insert into public.memberships (profile_id, operator_id, role)
  values (caller, new_id, 'owner');

  return new_id;
end;
$$;
revoke execute on function public.create_operator(text, text, text, text) from public, anon;
grant execute on function public.create_operator(text, text, text, text) to authenticated;
