import { useTranslation } from 'react-i18next';
import { StyleSheet } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { AppText } from '@/components/app-text';
import { useTheme } from '@/theme';

import type { PushStatus } from '../domain/push-token';

type PushDeniedNoticeProps = { status: PushStatus | null };

const MESSAGES: Partial<Record<PushStatus, string>> = {
  denied: 'notifications.denied',
  unavailable: 'notifications.unavailable',
};

// sin permiso o sin push en el dispositivo: aviso discreto, la app sigue
export function PushDeniedNotice({ status }: PushDeniedNoticeProps) {
  const { t } = useTranslation();
  const { colors, spacing } = useTheme();
  const message = status ? MESSAGES[status] : undefined;
  if (!message) return null;
  return (
    <SafeAreaView
      edges={['bottom']}
      accessibilityRole="alert"
      style={[styles.bar, { backgroundColor: colors.surface, borderTopColor: colors.border, padding: spacing.md }]}
    >
      <AppText variant="caption" tone="muted">
        {t(message)}
      </AppText>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({ bar: { borderTopWidth: StyleSheet.hairlineWidth } });
