import { createContext, type ReactNode } from 'react';

import type { AuthGateway } from '../domain/auth-gateway';

// el gateway real se elige en app/_layout.tsx; los tests inyectan uno falso
export const AuthGatewayContext = createContext<AuthGateway | null>(null);

type AuthGatewayProviderProps = { gateway: AuthGateway; children: ReactNode };

export function AuthGatewayProvider({ gateway, children }: AuthGatewayProviderProps) {
  return <AuthGatewayContext value={gateway}>{children}</AuthGatewayContext>;
}
