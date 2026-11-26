import { act, renderHook } from '@testing-library/react-native';

import { createFakePushProvider, createFakePushStore } from '../../testing/fake-push';
import { pushWrapper } from '../../testing/push-wrapper';
import { useClearPushToken } from './use-clear-push-token';
import { usePushRegistration } from './use-push-registration';

const SESSION = { userId: 'user-1' };

function useSignedInPush() {
  usePushRegistration(SESSION);
  return useClearPushToken();
}

describe('useClearPushToken', () => {
  it('returns a function that clears the token of the profile', async () => {
    const store = createFakePushStore();
    const wrapper = pushWrapper({ provider: createFakePushProvider().provider, store });
    const { result } = await renderHook(() => useClearPushToken(), { wrapper });

    await result.current();

    expect(store.clear).toHaveBeenCalled();
  });

  // cerrar sesión mientras el registro sigue en vuelo: la última escritura es el borrado
  it('leaves the token cleared when a registration lands after sign-out starts', async () => {
    const fake = createFakePushProvider();
    let release: (token: string) => void = () => undefined;
    fake.provider.getToken.mockImplementationOnce(() => new Promise((done) => (release = done)));
    const store = createFakePushStore();
    const { result } = await renderHook(() => useSignedInPush(), { wrapper: pushWrapper({ provider: fake.provider, store }) });

    await act(async () => {
      const clearing = result.current();
      release('ExpoPushToken[late]');
      await clearing;
    });
    await act(async () => fake.emitToken('ExpoPushToken[rotated]'));

    expect(store.clear).toHaveBeenCalled();
    expect(store.save).not.toHaveBeenCalled();
  });

  it('clears only after a save already in progress finishes', async () => {
    const fake = createFakePushProvider();
    const store = createFakePushStore();
    let finish: () => void = () => undefined;
    store.save.mockImplementationOnce(() => new Promise((done) => (finish = done)));
    const { result } = await renderHook(() => useSignedInPush(), { wrapper: pushWrapper({ provider: fake.provider, store }) });
    expect(store.save).toHaveBeenCalled();

    let clearing: Promise<void> = Promise.resolve();
    await act(async () => {
      clearing = result.current();
    });
    expect(store.clear).not.toHaveBeenCalled();

    await act(async () => {
      finish();
      await clearing;
    });
    expect(store.clear).toHaveBeenCalled();
  });
});
