import { createContext, type ReactNode } from 'react';

import type { PushRegistry } from '../domain/push-token';

// la implementación real se elige en app/_layout.tsx; los tests inyectan dobles
export const PushRegistryContext = createContext<PushRegistry | null>(null);

type PushRegistryProviderProps = { registry: PushRegistry; children: ReactNode };

export function PushRegistryProvider({ registry, children }: PushRegistryProviderProps) {
  return <PushRegistryContext value={registry}>{children}</PushRegistryContext>;
}
