import type { SupabaseClient } from '@supabase/supabase-js';

import type { Database } from '@ridy/shared';

import { getSupabase } from '@/services/supabase';

import type { PushTokenStore } from '../domain/push-token';

export type PushTokenClient = Pick<SupabaseClient<Database>, 'rpc'>;

type RpcResult = { error: Error | null };

function throwIfFailed({ error }: RpcResult): void {
  if (error) throw error;
}

// única vía de escritura: set_push_token quita el token de otros perfiles (un teléfono = un dueño)
export function createSupabasePushTokenStore(getClient: () => PushTokenClient = getSupabase): PushTokenStore {
  return {
    async save(token) {
      throwIfFailed(await getClient().rpc('set_push_token', { token }));
    },
    async clear() {
      throwIfFailed(await getClient().rpc('set_push_token', {}));
    },
  };
}
