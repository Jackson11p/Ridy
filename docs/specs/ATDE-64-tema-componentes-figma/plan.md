# ATDE-64 — Plan

## Fuente de verdad

Variables de Figma (`get_variable_defs` sobre `4:2` claro y `28:121` oscuro):

| Token | Claro | Oscuro |
|---|---|---|
| background | `#F5F7FB` | `#0B1424` |
| surface | `#FFFFFF` | `#142238` |
| text | `#10233F` | `#F4F7FC` |
| muted | `#59687D` | `#B1BFD1` |
| border | `#DCE3EC` | `#34465F` |
| action / onAction | `#0962D9` / `#FFFFFF` | `#0962D9` / `#FFFFFF` |
| accent | `#1677FF` | `#72AEFF` |
| danger (texto) / dangerAction | `#B52337` / `#E63946` | `#FF8FA1` / `#B52337` |
| disabled | `#DCE3EC` | `#263750` |
| info/success/warning/dangerBg | `#EAF2FF` `#E6F5EE` `#FFF3D4` `#FDECEF` | `#183453` `#12392F` `#3C301B` `#402231` |

Tipografía (tamaño/interlineado/peso): display 40/48/700 · body 16/24/400 · label 16/24/600 · button 18/24/600 · caption 13/20/400.
Radio control 14. Espaciado base 4: 4, 8, 12, 16, 20, 24, 32. Botón alto 56. Margen lateral de pantalla 20.

## Módulos

1. **`src/theme/`** — `palette.ts` (dos paletas con el mismo tipo), `typography.ts`, `spacing.ts` (espaciado, radios, alturas), `use-theme.ts` (elige paleta con `useColorScheme` de `react-native`, sin deps), `index.ts`. Se borra `colors.ts`.
2. **`src/components/`** — `app-text.tsx` (prop `variant`, `tone`), `button.tsx` (prop `variant`, `disabled`, `loading`), `text-field.tsx` (`label`, `error`, `disabled`, resto de `TextInput`), `screen.tsx` (SafeArea + fondo + margen). Cada uno con su `.test.tsx`.
3. **Migración** — `ScreenTitle` pasa a `AppText variant="display"` con rol header; `PlaceholderScreen` usa `Screen`.
4. **Docs** — decisión D10 (prototipo Figma canónico) y fuente Inter en Abiertas; `docs/contexto/figma.md` con link, ids de página y receta para pedir pantallas; `.mcp.json` con el servidor remoto de Figma.

## Decisiones de diseño

- Estilos por función `makeStyles(theme)` + `useMemo` dentro del componente: sin librería de estilos.
- Componentes no conocen i18n: reciben textos por props.
- Variante → colores por mapa tipado, no `if` encadenados (funciones < 30 líneas).
- Tests: render con cada variante, rol/estado accesible, `onPress` bloqueado en deshabilitado/cargando, y paleta oscura con `useColorScheme` mockeado.
- Archivos < 150 líneas; si un componente crece, sus estilos van a `*.styles.ts`.

## Riesgos

- Fuente del sistema ≠ Inter: diferencia visual menor hasta decidir la dep.
- `useColorScheme` puede devolver `null`: se toma claro por defecto.
