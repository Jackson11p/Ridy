export { darkPalette, lightPalette, type Palette } from './palette';
export { borders, radius, sizes, spacing } from './spacing';
export { typography, type TypographyVariant } from './typography';
// el hook vive en src/hooks/ (ATDE-15-T16); se reexporta para no tocar imports
export { useTheme, type Theme } from '@/hooks/use-theme';
