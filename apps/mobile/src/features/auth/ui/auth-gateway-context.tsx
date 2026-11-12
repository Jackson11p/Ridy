import { createContext, useContext, type ReactNode } from 'react';

import type { AuthGateway } from '../domain/auth-gateway';
import { createSupabaseAuthGateway } from '../infrastructure/supabase-auth-gateway';

// el gateway real no toca Supabase hasta el primer uso; los tests inyectan uno falso
const AuthGatewayContext = createContext<AuthGateway>(createSupabaseAuthGateway());

type AuthGatewayProviderProps = { gateway: AuthGateway; children: ReactNode };

export function AuthGatewayProvider({ gateway, children }: AuthGatewayProviderProps) {
  return <AuthGatewayContext value={gateway}>{children}</AuthGatewayContext>;
}

export function useAuthGateway(): AuthGateway {
  return useContext(AuthGatewayContext);
}
