import { useEffect, useState } from 'react';

import type { Session } from '../../domain/auth-gateway';
import { useAuthGateway } from './use-auth-gateway';

type SessionState = { loading: boolean; session: Session | null };

export function useSession(): SessionState {
  const gateway = useAuthGateway();
  const [state, setState] = useState<SessionState>({ loading: true, session: null });

  useEffect(() => {
    let active = true;
    const stop = gateway.onSessionChange((session) => setState({ loading: false, session }));
    gateway
      .getSession()
      .catch(() => null)
      // un cambio ya recibido gana a la lectura inicial
      .then((session) => active && setState((prev) => (prev.loading ? { loading: false, session } : prev)));
    return () => {
      active = false;
      stop();
    };
  }, [gateway]);

  return state;
}
