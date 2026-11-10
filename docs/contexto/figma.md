# Figma — prototipo de Ridy

> Decisión D10 (`decisiones.md`). Tokens y componentes base: ATDE-64.

## Archivo

- Link: https://www.figma.com/design/pFcHPqTQVk7p0DrUnNdPvU
- Páginas: claro `0:1`, oscuro `25:172`.
- MCP: `.mcp.json` en la raíz registra el servidor remoto `figma` (`https://mcp.figma.com/mcp`); cada dev se autentica con su cuenta.

## Prefijos de frames

| Prefijo | Área |
|---|---|
| A | Acceso (login, OTP, registro) |
| P | Familia (padres) |
| C | Chofer |
| D | Administración (transportista) |
| E | Extras |

## Receta para pedir una pantalla a Claude

1. Copiar la URL del frame con `node-id` (clic derecho → *Copy link to selection*).
2. Pedir: "Implementa la pantalla `<URL>` en `<ruta de app/>` según la spec `<TICKET>`".
3. Reglas que Claude debe seguir:
   - Solo `@/theme` (`useTheme`, tokens) y `@/components` (`Screen`, `AppText`, `Button`, `TextField`).
   - Nada literal: ni colores hex ni `fontSize`/medidas sueltas; si falta un token, se agrega en `src/theme/` con test.
   - Textos por i18n en la pantalla; los componentes solo reciben props.
   - Test primero (`jest-expo` + RNTL), verlo fallar, luego código.
4. Revisar en claro y oscuro (modo del teléfono).
