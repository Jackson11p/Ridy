import type { PushPermission, PushTokenProvider, PushTokenStore, TokenListener } from '../domain/push-token';

type FakeProviderOptions = { permission?: PushPermission; token?: string | null };

// dobles de pruebas compartidos por application, ui y rutas: sin nativo ni Supabase
export function createFakePushProvider({ permission = 'granted', token = 'ExpoPushToken[fake]' }: FakeProviderOptions = {}) {
  const listeners = new Set<TokenListener>();
  const provider = {
    requestPermission: jest.fn(async () => permission),
    getToken: jest.fn(async () => token),
    onTokenChange: jest.fn((listener: TokenListener) => {
      listeners.add(listener);
      return () => listeners.delete(listener);
    }),
  } satisfies PushTokenProvider;
  const emitToken = (next: string) => listeners.forEach((listener) => listener(next));
  return { provider, emitToken, listeners };
}

export function createFakePushStore() {
  return {
    save: jest.fn<Promise<void>, [string]>(async () => undefined),
    clear: jest.fn(async () => undefined),
  } satisfies PushTokenStore;
}
