import { useColorScheme } from 'react-native';

import { darkPalette, lightPalette, type Palette } from './palette';
import { radius, sizes, spacing } from './spacing';
import { typography } from './typography';

export type Theme = {
  colors: Palette;
  typography: typeof typography;
  spacing: typeof spacing;
  radius: typeof radius;
  sizes: typeof sizes;
};

const tokens = { typography, spacing, radius, sizes };
const lightTheme: Theme = { colors: lightPalette, ...tokens };
const darkTheme: Theme = { colors: darkPalette, ...tokens };

export function useTheme(): Theme {
  return useColorScheme() === 'dark' ? darkTheme : lightTheme;
}
