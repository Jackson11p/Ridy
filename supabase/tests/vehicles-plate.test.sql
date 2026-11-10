-- ATDE-9-T07: placa única por empresa sin distinguir mayúsculas ni espacios.
begin;
create extension if not exists pgtap with schema extensions;
select plan(7);

insert into public.operators (id, name, country, currency, timezone) values
  ('00000000-0000-0000-0000-00000004aaaa', 'Busetas A', 'CR', 'CRC', 'America/Costa_Rica'),
  ('00000000-0000-0000-0000-00000004bbbb', 'Busetas B', 'CR', 'CRC', 'America/Costa_Rica');
insert into public.vehicles (id, operator_id, plate, capacity) values
  ('00000000-0000-0000-0000-0000000041a1', '00000000-0000-0000-0000-00000004aaaa', 'AAA111', 20),
  ('00000000-0000-0000-0000-0000000041a2', '00000000-0000-0000-0000-00000004aaaa', 'BBB222', 20);

select throws_ok($$insert into public.vehicles (operator_id, plate, capacity)
  values ('00000000-0000-0000-0000-00000004aaaa', 'aaa111', 10)$$, '23505', null, 'placa repetida en minúsculas');
select throws_ok($$insert into public.vehicles (operator_id, plate, capacity)
  values ('00000000-0000-0000-0000-00000004aaaa', 'AAA 111', 10)$$, '23505', null, 'placa repetida con espacio');
select throws_ok($$insert into public.vehicles (operator_id, plate, capacity)
  values ('00000000-0000-0000-0000-00000004aaaa', ' aAa 1 1 1 ', 10)$$, '23505', null, 'placa repetida con mezcla');
select throws_ok($$update public.vehicles set plate = 'aaa 111'
  where id = '00000000-0000-0000-0000-0000000041a2'$$, '23505', null, 'update a placa repetida rechazado');
select lives_ok($$insert into public.vehicles (operator_id, plate, capacity)
  values ('00000000-0000-0000-0000-00000004bbbb', 'aaa 111', 10)$$, 'misma placa normalizada en otra empresa');
select lives_ok($$insert into public.vehicles (operator_id, plate, capacity)
  values ('00000000-0000-0000-0000-00000004aaaa', 'AAA-111', 10)$$, 'solo se ignoran espacios, no guiones');
select has_index('public', 'vehicles', 'vehicles_operator_id_plate_normalized_key', 'índice único de placa normalizada');

select * from finish();
rollback;
