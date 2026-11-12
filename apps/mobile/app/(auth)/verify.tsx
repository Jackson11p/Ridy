import { Redirect, useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';

import { BackHeader } from '@/components/back-header';
import { Button } from '@/components/button';
import { ScreenIntro } from '@/components/screen-intro';
import { AuthScreen, CodeField, formatPhone, ResendAction, useCodeForm, useErrorText } from '@/features/auth';

export default function Verify() {
  const { t } = useTranslation();
  const router = useRouter();
  const { phone = '' } = useLocalSearchParams<{ phone?: string }>();
  const toSignIn = () => router.replace('/sign-in');
  const form = useCodeForm(phone, () => router.replace('/children'));
  const error = useErrorText(form.error);

  if (!phone) return <Redirect href="/sign-in" />;

  return (
    <AuthScreen>
      <BackHeader label={t('auth.verify.header')} onPress={toSignIn} />
      <ScreenIntro
        title={t(error ? 'auth.verify.retryTitle' : 'auth.verify.title')}
        subtitle={error ? undefined : t('auth.verify.sentTo', { phone: formatPhone(phone) })}
      />
      <CodeField value={form.code} onChangeText={form.setCode} onSubmit={form.verify} error={error} />
      <Button label={t('auth.verify.submit')} loading={form.submitting} onPress={form.verify} />
      <ResendAction secondsLeft={form.secondsLeft} disabled={form.submitting} onResend={form.resend} />
      <Button label={t('auth.verify.changePhone')} variant="text" onPress={toSignIn} />
    </AuthScreen>
  );
}
