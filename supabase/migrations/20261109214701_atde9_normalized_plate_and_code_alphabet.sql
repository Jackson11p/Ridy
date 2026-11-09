-- ATDE-9-T07: placa única por empresa sin distinguir mayúsculas ni espacios;
-- check de código alineado con el alfabeto de private.generate_route_code (sin 0/O/1/I).
alter table public.vehicles drop constraint vehicles_operator_id_plate_key;
create unique index vehicles_operator_id_plate_normalized_key
  on public.vehicles (operator_id, upper(regexp_replace(plate, '\s', '', 'g')));

alter table public.routes drop constraint routes_code_check;
alter table public.routes add constraint routes_code_check
  check (code ~ '^RDY-[A-HJ-NP-Z2-9]{6}$');
