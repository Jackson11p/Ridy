import { View } from 'react-native';

import { AppText } from './app-text';
import { useTheme } from '@/theme';

type ScreenIntroProps = { title: string; subtitle?: string };

export function ScreenIntro({ title, subtitle }: ScreenIntroProps) {
  const { spacing } = useTheme();
  return (
    <View style={{ gap: spacing.md }}>
      <AppText variant="title" accessibilityRole="header">
        {title}
      </AppText>
      {subtitle ? <AppText tone="muted">{subtitle}</AppText> : null}
    </View>
  );
}
