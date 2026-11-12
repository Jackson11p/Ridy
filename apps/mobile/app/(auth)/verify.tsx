import { Redirect, useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { View } from 'react-native';

import { AppText } from '@/components/app-text';
import { Button } from '@/components/button';
import { Screen } from '@/components/screen';
import { TextField } from '@/components/text-field';
import { CODE_LENGTH, formatCountdown, formatPhone, useCodeForm } from '@/features/auth';
import { useTheme } from '@/theme';

export default function Verify() {
  const { t } = useTranslation();
  const router = useRouter();
  const { spacing, sizes } = useTheme();
  const { phone = '' } = useLocalSearchParams<{ phone?: string }>();
  const toSignIn = () => router.replace('/sign-in');
  const form = useCodeForm(phone, () => router.replace('/children'));

  if (!phone) return <Redirect href="/sign-in" />;

  return (
    <Screen scroll contentStyle={{ gap: spacing.xxl, paddingVertical: spacing.xxl }}>
      <AppText
        variant="heading"
        accessibilityRole="button"
        accessibilityLabel={t('auth.verify.back')}
        onPress={toSignIn}
        style={{ minHeight: sizes.touchTarget }}
      >
        {`‹ ${t('auth.verify.header')}`}
      </AppText>
      <View style={{ gap: spacing.md }}>
        <AppText variant="title" accessibilityRole="header">
          {t(form.error ? 'auth.verify.retryTitle' : 'auth.verify.title')}
        </AppText>
        {form.error ? null : <AppText tone="muted">{t('auth.verify.sentTo', { phone: formatPhone(phone) })}</AppText>}
      </View>
      <TextField
        label={t('auth.verify.codeLabel')}
        keyboardType="number-pad"
        textContentType="oneTimeCode"
        autoComplete="sms-otp"
        maxLength={CODE_LENGTH}
        value={form.code}
        onChangeText={form.setCode}
        onSubmitEditing={form.verify}
        error={form.error ? t(`auth.errors.${form.error}`) : undefined}
      />
      <Button label={t('auth.verify.submit')} loading={form.submitting} onPress={form.verify} />
      {form.secondsLeft > 0 ? (
        <AppText variant="caption" tone="muted">
          {t('auth.verify.resendIn', { time: formatCountdown(form.secondsLeft) })}
        </AppText>
      ) : (
        <Button label={t('auth.verify.resend')} variant="secondary" disabled={form.submitting} onPress={form.resend} />
      )}
      <Button label={t('auth.verify.changePhone')} variant="text" onPress={toSignIn} />
    </Screen>
  );
}
