# ATDE-7 — Runner de tests y pruebas RLS locales

## Problema

La constitución (§5) exige TDD y una prueba RLS por cada tabla con políticas. El runner JS existe (ATDE-6), pero no hay `supabase/tests/` ni script para correr pruebas SQL/RLS contra el stack local.

## Objetivo

Que cualquier dev, con Supabase local arriba, corra los tests JS y las pruebas RLS con un comando cada uno, y tenga un ejemplo a copiar para la primera migración (ATDE-8).

## Criterios de aceptación

1. `pnpm test` en la raíz corre los tests JS (jest-expo).
2. `pnpm test:db` corre `supabase/tests/*.test.sql` contra el stack local.
3. Prueba RLS de ejemplo simula `anon` y dos usuarios `authenticated` distintos: cada uno ve solo sus filas; `anon` no ve nada.
4. README documenta cómo correr ambas suites.

## Fuera de alcance

- Tablas reales del dominio (ATDE-8) y job CI `test-rls` (ATDE-12).

## Supuestos

- Ticket Jira `ATDE-7`; rama y carpeta `ATDE-7-runner-tests-rls`; tareas `ATDE-7-Tnn`.
- Runner SQL según ADR-0001: pgTAP vía `supabase test db` (CLI ya instalado, sin deps nuevas).
- La tabla del ejemplo se crea dentro de la transacción de la prueba y se deshace con `rollback`: no toca el esquema, así que no viola "esquema solo por migraciones".
- Criterio 1 ya lo cumple ATDE-6 (`pnpm -r --if-present test`); solo se verifica y documenta.
