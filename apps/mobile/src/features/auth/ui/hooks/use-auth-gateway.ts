import { useContext } from 'react';

import type { AuthGateway } from '../../domain/auth-gateway';
import { AuthGatewayContext } from '../auth-gateway-context';

export function useAuthGateway(): AuthGateway {
  const gateway = useContext(AuthGatewayContext);
  if (!gateway) throw new Error('Falta AuthGatewayProvider: móntalo en app/_layout.tsx.');
  return gateway;
}
