import { useContext } from 'react';

import type { PushRegistry } from '../../domain/push-token';
import { PushRegistryContext } from '../push-registry-context';

export function usePushRegistry(): PushRegistry {
  const registry = useContext(PushRegistryContext);
  if (!registry) throw new Error('Falta PushRegistryProvider: móntalo en app/_layout.tsx.');
  return registry;
}
