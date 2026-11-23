import { useState } from 'react';

import { requestCode } from '../../application/request-code';
import { useAuthGateway } from './use-auth-gateway';
import { useSubmission } from './use-submission';

export function usePhoneForm(onSent: (phone: string) => void) {
  const gateway = useAuthGateway();
  const { submitting, error, clearError, run } = useSubmission();
  const [value, setRawValue] = useState('');

  const setValue = (next: string) => {
    setRawValue(next);
    clearError();
  };

  const submit = () => run(async () => onSent(await requestCode(gateway, value)));

  return { value, setValue, error, submitting, submit };
}
