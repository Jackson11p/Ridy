import { expoPushTokenSchema } from '@ridy/shared';

import type { PushStatus, PushTokenProvider, PushTokenStore } from '../domain/push-token';

export async function savePushToken(store: PushTokenStore, token: string | null): Promise<PushStatus> {
  const parsed = expoPushTokenSchema.safeParse(token);
  if (!parsed.success) return 'unavailable';
  await store.save(parsed.data);
  return 'registered';
}

export async function registerPushToken(provider: PushTokenProvider, store: PushTokenStore): Promise<PushStatus> {
  const permission = await provider.requestPermission();
  if (permission !== 'granted') return permission;
  return savePushToken(store, await provider.getToken());
}

export function unregisterPushToken(store: PushTokenStore): Promise<void> {
  return store.clear();
}
