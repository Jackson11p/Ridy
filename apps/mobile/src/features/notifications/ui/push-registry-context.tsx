import { createContext, useMemo, type ReactNode } from 'react';

import { createSerialPushStore, type SerialPushStore } from '../application/serial-push-store';
import type { PushRegistry, PushTokenProvider } from '../domain/push-token';

export type SerialPushRegistry = { provider: PushTokenProvider; store: SerialPushStore };

// la implementación real se elige en app/_layout.tsx; los tests inyectan dobles
export const PushRegistryContext = createContext<SerialPushRegistry | null>(null);

type PushRegistryProviderProps = { registry: PushRegistry; children: ReactNode };

// un solo store serial por app: registro, rotación y borrado comparten la cola
export function PushRegistryProvider({ registry, children }: PushRegistryProviderProps) {
  const { provider, store } = registry;
  const value = useMemo(() => ({ provider, store: createSerialPushStore(store) }), [provider, store]);
  return <PushRegistryContext value={value}>{children}</PushRegistryContext>;
}
