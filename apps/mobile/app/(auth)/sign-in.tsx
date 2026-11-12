import { useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';

import { AppText } from '@/components/app-text';
import { Button } from '@/components/button';
import { ScreenIntro } from '@/components/screen-intro';
import { TextField } from '@/components/text-field';
import { AuthScreen, useErrorText, usePhoneForm } from '@/features/auth';

export default function SignIn() {
  const { t } = useTranslation();
  const router = useRouter();
  const form = usePhoneForm((phone) => router.push({ pathname: '/verify', params: { phone } }));
  const error = useErrorText(form.error);

  return (
    <AuthScreen>
      <AppText variant="heading">{t('auth.signIn.welcome')}</AppText>
      <ScreenIntro title={t('auth.signIn.title')} subtitle={t('auth.signIn.subtitle')} />
      <TextField
        label={t('auth.signIn.phoneLabel')}
        prefix={t('auth.signIn.prefix')}
        placeholder={t('auth.signIn.phonePlaceholder')}
        keyboardType="phone-pad"
        autoComplete="tel"
        value={form.value}
        onChangeText={form.setValue}
        onSubmitEditing={form.submit}
        error={error}
      />
      <Button label={t('auth.signIn.submit')} loading={form.submitting} onPress={form.submit} />
      <AppText variant="caption" tone="muted">
        {t('auth.signIn.legal')}
      </AppText>
    </AuthScreen>
  );
}
