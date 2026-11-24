import { createSupabasePushTokenStore, type PushTokenClient } from './supabase-push-token-store';

function fakeClient(error: Error | null = null) {
  const client = { rpc: jest.fn(() => Promise.resolve({ error })) };
  return { client, store: createSupabasePushTokenStore(() => client as unknown as PushTokenClient) };
}

describe('supabasePushTokenStore', () => {
  it('saves the token through set_push_token', async () => {
    const { client, store } = fakeClient();

    await store.save('ExpoPushToken[abc]');

    expect(client.rpc).toHaveBeenCalledWith('set_push_token', { token: 'ExpoPushToken[abc]' });
  });

  it('clears the token calling set_push_token without a token', async () => {
    const { client, store } = fakeClient();

    await store.clear();

    expect(client.rpc).toHaveBeenCalledWith('set_push_token', {});
  });

  it('fails when the database rejects the call', async () => {
    const { store } = fakeClient(new Error('inactive profile'));

    await expect(store.save('ExpoPushToken[abc]')).rejects.toThrow('inactive profile');
    await expect(store.clear()).rejects.toThrow('inactive profile');
  });
});
