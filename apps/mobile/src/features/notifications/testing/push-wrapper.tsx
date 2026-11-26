import type { ReactNode } from 'react';

import type { PushRegistry } from '../domain/push-token';
import { PushRegistryProvider } from '../ui/push-registry-context';

// hooks y pantallas usan dobles: sin nativo ni Supabase
export function pushWrapper(registry: PushRegistry) {
  return function PushWrapper({ children }: { children: ReactNode }) {
    return <PushRegistryProvider registry={registry}>{children}</PushRegistryProvider>;
  };
}
