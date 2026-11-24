import { useCallback } from 'react';

import { unregisterPushToken } from '../../application/register-push-token';
import { usePushRegistry } from './use-push-registry';

// se pasa a useSignOut de auth: el token sale del perfil antes de cerrar sesión
export function useClearPushToken(): () => Promise<void> {
  const { store } = usePushRegistry();
  return useCallback(() => unregisterPushToken(store), [store]);
}
