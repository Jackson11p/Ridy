import type { TextStyle } from 'react-native';

type TextToken = Required<Pick<TextStyle, 'fontSize' | 'lineHeight' | 'fontWeight'>>;

export const typography = {
  display: { fontSize: 40, lineHeight: 48, fontWeight: '700' },
  body: { fontSize: 16, lineHeight: 24, fontWeight: '400' },
  label: { fontSize: 16, lineHeight: 24, fontWeight: '600' },
  button: { fontSize: 18, lineHeight: 24, fontWeight: '600' },
  caption: { fontSize: 13, lineHeight: 20, fontWeight: '400' },
} as const satisfies Record<string, TextToken>;

export type TypographyVariant = keyof typeof typography;
