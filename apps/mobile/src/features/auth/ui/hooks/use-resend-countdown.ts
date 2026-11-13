import { useEffect, useState } from 'react';

import { secondsUntilResend } from '../../domain/rules';

const TICK_MS = 1000;

export function useResendCountdown() {
  const [sentAt, setSentAt] = useState(() => Date.now());
  const [now, setNow] = useState(sentAt);
  const secondsLeft = secondsUntilResend(sentAt, now);

  useEffect(() => {
    if (secondsLeft === 0) return;
    const id = setInterval(() => setNow(Date.now()), TICK_MS);
    return () => clearInterval(id);
  }, [secondsLeft]);

  const restart = () => {
    const at = Date.now();
    setSentAt(at);
    setNow(at);
  };

  return { secondsLeft, restart };
}
