import { useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { View } from 'react-native';

import { AppText } from '@/components/app-text';
import { Button } from '@/components/button';
import { Screen } from '@/components/screen';
import { TextField } from '@/components/text-field';
import { usePhoneForm } from '@/features/auth';
import { useTheme } from '@/theme';

export default function SignIn() {
  const { t } = useTranslation();
  const router = useRouter();
  const { spacing } = useTheme();
  const form = usePhoneForm((phone) => router.push({ pathname: '/verify', params: { phone } }));

  return (
    <Screen scroll contentStyle={{ gap: spacing.xxl, paddingVertical: spacing.xxl }}>
      <AppText variant="heading">{t('auth.signIn.welcome')}</AppText>
      <View style={{ gap: spacing.md }}>
        <AppText variant="title" accessibilityRole="header">
          {t('auth.signIn.title')}
        </AppText>
        <AppText tone="muted">{t('auth.signIn.subtitle')}</AppText>
      </View>
      <TextField
        label={t('auth.signIn.phoneLabel')}
        prefix={t('auth.signIn.prefix')}
        placeholder={t('auth.signIn.phonePlaceholder')}
        keyboardType="phone-pad"
        autoComplete="tel"
        value={form.value}
        onChangeText={form.setValue}
        onSubmitEditing={form.submit}
        error={form.error ? t(`auth.errors.${form.error}`) : undefined}
      />
      <Button label={t('auth.signIn.submit')} loading={form.submitting} onPress={form.submit} />
      <AppText variant="caption" tone="muted">
        {t('auth.signIn.legal')}
      </AppText>
    </Screen>
  );
}
