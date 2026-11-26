import { useCallback } from 'react';

import { registerPushToken, unregisterPushToken } from '../../application/register-push-token';
import { usePushRegistry } from './use-push-registry';

// se pasa a useSignOut de auth: el token sale del perfil antes de cerrar sesión;
// si cerrar sesión falla, el undo reabre el store y vuelve a registrar el token
// (también si borrar falló: el store ya quedó cerrado a saves)
export function useClearPushToken(): () => Promise<() => void> {
  const { provider, store } = usePushRegistry();
  return useCallback(async () => {
    const undo = () => {
      store.open();
      void registerPushToken(provider, store).catch(() => undefined);
    };
    await unregisterPushToken(store).catch(() => undefined);
    return undo;
  }, [provider, store]);
}
