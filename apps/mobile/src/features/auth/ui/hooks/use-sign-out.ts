import { useCallback } from 'react';

import { signOut, type BeforeSignOut } from '../../application/sign-out';
import { useAuthGateway } from './use-auth-gateway';

// auth no conoce notificaciones: quien compone (app/) pasa la limpieza, p. ej. useClearPushToken()
export function useSignOut(beforeSignOut: BeforeSignOut): () => Promise<void> {
  const gateway = useAuthGateway();
  return useCallback(() => signOut(gateway, beforeSignOut), [gateway, beforeSignOut]);
}
