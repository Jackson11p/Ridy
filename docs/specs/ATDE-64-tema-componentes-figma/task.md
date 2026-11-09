# ATDE-64 — Tareas

- [x] ATDE-64-T01 Spec, plan y tareas
- [x] ATDE-64-T02 `src/theme/`: paletas claro/oscuro, tipografía, espaciado/radios y `useTheme` (sigue `useColorScheme`, `null` → claro); tests de tokens y selección; borrar `colors.ts`
- [x] ATDE-64-T03 `AppText` con variantes display/body/label/button/caption y tonos (text, muted, danger, onAction); test por variante y tema oscuro
- [ ] ATDE-64-T04 `Button` primario/secundario/peligro/texto, deshabilitado y cargando (sin `onPress`, `accessibilityState`), alto 56; tests
- [ ] ATDE-64-T05 `TextField` con etiqueta, error (texto y borde danger, anunciado) y deshabilitado; tests
- [ ] ATDE-64-T06 `Screen` (SafeArea, fondo del tema, margen 20, scroll opcional); migrar `ScreenTitle` y `PlaceholderScreen` sin literales; tests verdes
- [ ] ATDE-64-T07 Docs: D10 en `decisiones.md`, Inter en Abiertas, `docs/contexto/figma.md` (link, páginas, receta para pedir pantallas), `.mcp.json` con Figma; `arquitectura.md` marca `theme/` y `components/` [IMPL]
- [ ] ATDE-64-T08 `pnpm typecheck`, `pnpm lint`, `pnpm test` en verde; sin colores ni tamaños literales en `app/` y `src/components/` (grep)
