import { createFakePushProvider, createFakePushStore } from '../testing/fake-push';
import { registerPushToken, savePushToken, unregisterPushToken } from './register-push-token';

const TOKEN = 'ExponentPushToken[abc123]';

describe('registerPushToken', () => {
  it('asks permission, saves the Expo token and reports registered', async () => {
    const { provider } = createFakePushProvider({ permission: 'granted', token: TOKEN });
    const store = createFakePushStore();

    await expect(registerPushToken(provider, store)).resolves.toBe('registered');
    expect(provider.requestPermission).toHaveBeenCalled();
    expect(store.save).toHaveBeenCalledWith(TOKEN);
  });

  it.each(['denied', 'unavailable'] as const)('reports %s without asking for a token', async (permission) => {
    const { provider } = createFakePushProvider({ permission, token: TOKEN });
    const store = createFakePushStore();

    await expect(registerPushToken(provider, store)).resolves.toBe(permission);
    expect(provider.getToken).not.toHaveBeenCalled();
    expect(store.save).not.toHaveBeenCalled();
  });

  it.each([null, '', 'tok', 'FcmToken[abc]'])('reports unavailable and saves nothing for the token %p', async (token) => {
    const { provider } = createFakePushProvider({ permission: 'granted', token });
    const store = createFakePushStore();

    await expect(registerPushToken(provider, store)).resolves.toBe('unavailable');
    expect(store.save).not.toHaveBeenCalled();
  });

  it('lets a store failure reach the caller', async () => {
    const { provider } = createFakePushProvider({ permission: 'granted', token: TOKEN });
    const store = createFakePushStore();
    store.save.mockRejectedValueOnce(new Error('offline'));

    await expect(registerPushToken(provider, store)).rejects.toThrow('offline');
  });
});

describe('savePushToken', () => {
  it('saves a rotated valid token', async () => {
    const store = createFakePushStore();

    await expect(savePushToken(store, 'ExpoPushToken[new]')).resolves.toBe('registered');
    expect(store.save).toHaveBeenCalledWith('ExpoPushToken[new]');
  });

  it('ignores an invalid token', async () => {
    const store = createFakePushStore();

    await expect(savePushToken(store, 'garbage')).resolves.toBe('unavailable');
    expect(store.save).not.toHaveBeenCalled();
  });
});

describe('unregisterPushToken', () => {
  it('clears the token of the profile', async () => {
    const store = createFakePushStore();

    await unregisterPushToken(store);

    expect(store.clear).toHaveBeenCalled();
  });
});
