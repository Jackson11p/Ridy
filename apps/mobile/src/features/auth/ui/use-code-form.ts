import { useState } from 'react';

import { requestCode } from '../application/request-code';
import { verifyCode } from '../application/verify-code';
import { useAuthGateway } from './auth-gateway-context';
import { useResendCountdown } from './use-resend-countdown';
import { useSubmission } from './use-submission';

export function useCodeForm(phone: string, onVerified: () => void) {
  const gateway = useAuthGateway();
  const { secondsLeft, restart } = useResendCountdown();
  const { submitting, error, clearError, run } = useSubmission();
  const [code, setRawCode] = useState('');

  const setCode = (next: string) => {
    setRawCode(next);
    clearError();
  };

  const verify = () => run(async () => {
    await verifyCode(gateway, phone, code);
    onVerified();
  });

  const resend = () => run(async () => {
    if (secondsLeft > 0) return;
    await requestCode(gateway, phone);
    restart();
  });

  return { code, setCode, error, submitting, verify, resend, secondsLeft };
}
