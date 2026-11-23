import type { ReactNode } from 'react';

import type { AuthGateway } from '../domain/auth-gateway';
import { AuthGatewayProvider } from '../ui/auth-gateway-context';

// las pantallas usan un gateway falso: sin red ni Supabase
export function authWrapper(gateway: AuthGateway) {
  return function AuthWrapper({ children }: { children: ReactNode }) {
    return <AuthGatewayProvider gateway={gateway}>{children}</AuthGatewayProvider>;
  };
}
