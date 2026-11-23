import { useRef, useState } from 'react';

import { errorCodeOf, type AuthErrorCode } from '../../domain/auth-error';

// estado común de los formularios: enviando, error y una sola acción en vuelo
export function useSubmission() {
  const inFlight = useRef(false);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<AuthErrorCode | null>(null);

  const run = async (action: () => Promise<void>) => {
    if (inFlight.current) return;
    inFlight.current = true;
    setSubmitting(true);
    setError(null);
    try {
      await action();
    } catch (caught) {
      setError(errorCodeOf(caught));
    } finally {
      inFlight.current = false;
      setSubmitting(false);
    }
  };

  return { submitting, error, clearError: () => setError(null), run };
}
