import { useColorScheme } from 'react-native';

import { darkPalette, lightPalette, type Palette } from '@/theme/palette';
import { borders, radius, sizes, spacing } from '@/theme/spacing';
import { typography } from '@/theme/typography';

export type Theme = {
  colors: Palette;
  typography: typeof typography;
  spacing: typeof spacing;
  radius: typeof radius;
  borders: typeof borders;
  sizes: typeof sizes;
};

const tokens = { typography, spacing, radius, borders, sizes };
const lightTheme: Theme = { colors: lightPalette, ...tokens };
const darkTheme: Theme = { colors: darkPalette, ...tokens };

export function useTheme(): Theme {
  return useColorScheme() === 'dark' ? darkTheme : lightTheme;
}
