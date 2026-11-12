import { useState } from 'react';

import { requestCode } from '../application/request-code';
import { verifyCode } from '../application/verify-code';
import { errorCodeOf, type AuthErrorCode } from '../domain/auth-error';
import { useAuthGateway } from './auth-gateway-context';
import { useResendCountdown } from './use-resend-countdown';

export function useCodeForm(phone: string, onVerified: () => void) {
  const gateway = useAuthGateway();
  const countdown = useResendCountdown();
  const [code, setRawCode] = useState('');
  const [error, setError] = useState<AuthErrorCode | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const run = async (action: () => Promise<void>) => {
    setSubmitting(true);
    setError(null);
    try {
      await action();
    } catch (caught) {
      setError(errorCodeOf(caught));
    } finally {
      setSubmitting(false);
    }
  };

  const setCode = (next: string) => {
    setRawCode(next);
    setError(null);
  };

  const verify = () => run(async () => {
    await verifyCode(gateway, phone, code);
    onVerified();
  });

  const resend = async () => {
    if (countdown.secondsLeft > 0) return;
    await run(async () => {
      await requestCode(gateway, phone);
      countdown.restart();
    });
  };

  return { code, setCode, error, submitting, verify, resend, secondsLeft: countdown.secondsLeft };
}
