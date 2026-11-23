import type { ReactNode } from 'react';

import { Screen } from '@/components/screen';
import { useTheme } from '@/theme';

export function AuthScreen({ children }: { children: ReactNode }) {
  const { spacing } = useTheme();
  return (
    <Screen scroll contentStyle={{ gap: spacing.xxl, paddingVertical: spacing.xxl }}>
      {children}
    </Screen>
  );
}
