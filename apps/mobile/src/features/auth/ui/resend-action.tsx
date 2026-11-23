import { useTranslation } from 'react-i18next';

import { AppText } from '@/components/app-text';
import { Button } from '@/components/button';

import { formatCountdown } from '../domain/rules';

type ResendActionProps = { secondsLeft: number; disabled: boolean; onResend: () => void };

export function ResendAction({ secondsLeft, disabled, onResend }: ResendActionProps) {
  const { t } = useTranslation();
  if (secondsLeft === 0) {
    return <Button label={t('auth.verify.resend')} variant="secondary" disabled={disabled} onPress={onResend} />;
  }
  return (
    <AppText variant="caption" tone="muted">
      {t('auth.verify.resendIn', { time: formatCountdown(secondsLeft) })}
    </AppText>
  );
}
