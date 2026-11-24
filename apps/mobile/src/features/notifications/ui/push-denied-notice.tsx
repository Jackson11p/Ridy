import { useTranslation } from 'react-i18next';
import { StyleSheet } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { AppText } from '@/components/app-text';
import { useTheme } from '@/theme';

import type { PushStatus } from '../domain/push-token';

type PushDeniedNoticeProps = { status: PushStatus | null };

export function PushDeniedNotice({ status }: PushDeniedNoticeProps) {
  const { t } = useTranslation();
  const { colors, spacing } = useTheme();
  if (status !== 'denied') return null;
  return (
    <SafeAreaView
      edges={['bottom']}
      accessibilityRole="alert"
      style={[styles.bar, { backgroundColor: colors.surface, borderTopColor: colors.border, padding: spacing.md }]}
    >
      <AppText variant="caption" tone="muted">
        {t('notifications.denied')}
      </AppText>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({ bar: { borderTopWidth: StyleSheet.hairlineWidth } });
