import { Text, type TextProps } from 'react-native';

import { useTheme, type TypographyVariant } from '@/theme';

export type AppTextTone = 'text' | 'muted' | 'danger' | 'onAction' | 'action';

type AppTextProps = TextProps & { variant?: TypographyVariant; tone?: AppTextTone };

export function AppText({ variant = 'body', tone = 'text', style, ...rest }: AppTextProps) {
  const theme = useTheme();
  return <Text style={[theme.typography[variant], { color: theme.colors[tone] }, style]} {...rest} />;
}
