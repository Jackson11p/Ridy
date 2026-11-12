import { useState } from 'react';

import { requestCode } from '../application/request-code';
import { errorCodeOf, type AuthErrorCode } from '../domain/auth-error';
import { useAuthGateway } from './auth-gateway-context';

export function usePhoneForm(onSent: (phone: string) => void) {
  const gateway = useAuthGateway();
  const [value, setRawValue] = useState('');
  const [error, setError] = useState<AuthErrorCode | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const setValue = (next: string) => {
    setRawValue(next);
    setError(null);
  };

  const submit = async () => {
    setSubmitting(true);
    try {
      onSent(await requestCode(gateway, value));
    } catch (caught) {
      setError(errorCodeOf(caught));
    } finally {
      setSubmitting(false);
    }
  };

  return { value, setValue, error, submitting, submit };
}
