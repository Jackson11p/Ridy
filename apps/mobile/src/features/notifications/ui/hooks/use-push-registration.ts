import { useEffect, useState } from 'react';

import { registerPushToken, savePushToken } from '../../application/register-push-token';
import type { PushStatus } from '../../domain/push-token';
import { usePushRegistry } from './use-push-registry';

type SignedIn = { userId: string } | null;

type PushRegistrationState = { status: PushStatus | null };

// con sesión: registra el token y re-guarda si rota; fallos de red no rompen la app
export function usePushRegistration(session: SignedIn): PushRegistrationState {
  const { provider, store } = usePushRegistry();
  const [status, setStatus] = useState<PushStatus | null>(null);
  const userId = session?.userId ?? null;

  useEffect(() => {
    if (!userId) return;
    let active = true;
    registerPushToken(provider, store)
      .catch((): PushStatus => 'unavailable')
      .then((next) => active && setStatus(next));
    const stop = provider.onTokenChange((token) => void savePushToken(store, token).catch(() => undefined));
    return () => {
      active = false;
      stop();
    };
  }, [userId, provider, store]);

  return { status: userId ? status : null };
}
