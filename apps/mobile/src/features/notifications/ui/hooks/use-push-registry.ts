import { useContext } from 'react';

import { PushRegistryContext, type SerialPushRegistry } from '../push-registry-context';

export function usePushRegistry(): SerialPushRegistry {
  const registry = useContext(PushRegistryContext);
  if (!registry) throw new Error('Falta PushRegistryProvider: móntalo en app/_layout.tsx.');
  return registry;
}
