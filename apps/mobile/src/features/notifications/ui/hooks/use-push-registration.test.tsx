import { act, renderHook } from '@testing-library/react-native';

import { pushWrapper } from '../../testing/push-wrapper';
import { createFakePushProvider, createFakePushStore } from '../../testing/fake-push';
import { usePushRegistration } from './use-push-registration';
import { usePushRegistry } from './use-push-registry';

const SESSION = { userId: 'user-1' };

function setup(options: Parameters<typeof createFakePushProvider>[0] = {}) {
  const fake = createFakePushProvider(options);
  const store = createFakePushStore();
  const wrapper = pushWrapper({ provider: fake.provider, store });
  return { ...fake, store, wrapper };
}

describe('usePushRegistration', () => {
  it('registers the token when there is a session', async () => {
    const { store, wrapper } = setup({ token: 'ExpoPushToken[a]' });

    const { result } = await renderHook(() => usePushRegistration(SESSION), { wrapper });

    expect(result.current.status).toBe('registered');
    expect(store.save).toHaveBeenCalledWith('ExpoPushToken[a]');
  });

  it('does nothing without a session', async () => {
    const { provider, store, wrapper } = setup();

    const { result } = await renderHook(() => usePushRegistration(null), { wrapper });

    expect(result.current.status).toBeNull();
    expect(provider.requestPermission).not.toHaveBeenCalled();
    expect(provider.onTokenChange).not.toHaveBeenCalled();
    expect(store.save).not.toHaveBeenCalled();
  });

  it('exposes denied when the user refuses permission', async () => {
    const { wrapper } = setup({ permission: 'denied' });

    const { result } = await renderHook(() => usePushRegistration(SESSION), { wrapper });

    expect(result.current.status).toBe('denied');
  });

  it('reports unavailable when saving fails, without breaking the app', async () => {
    const { store, wrapper } = setup();
    store.save.mockRejectedValueOnce(new Error('offline'));

    const { result } = await renderHook(() => usePushRegistration(SESSION), { wrapper });

    expect(result.current.status).toBe('unavailable');
  });

  it('saves a rotated token and stops listening when the session ends', async () => {
    const { emitToken, listeners, store, wrapper } = setup();
    const { rerender } = await renderHook(({ session }: { session: typeof SESSION | null }) => usePushRegistration(session), {
      wrapper,
      initialProps: { session: SESSION },
    });

    await act(async () => emitToken('ExpoPushToken[rotated]'));
    expect(store.save).toHaveBeenLastCalledWith('ExpoPushToken[rotated]');

    await rerender({ session: null });
    expect(listeners.size).toBe(0);
  });

  // otra persona en el mismo teléfono no hereda el estado de la anterior mientras registra
  it('resets the status when the signed-in user changes', async () => {
    const { provider, wrapper } = setup({ permission: 'denied' });
    const { result, rerender } = await renderHook(({ session }: { session: typeof SESSION }) => usePushRegistration(session), {
      wrapper,
      initialProps: { session: SESSION },
    });
    expect(result.current.status).toBe('denied');

    provider.requestPermission.mockImplementationOnce(() => new Promise(() => undefined));
    await rerender({ session: { userId: 'user-2' } });

    expect(result.current.status).toBeNull();
  });

  // tras cerrar sesión A, la siguiente persona en el teléfono sí guarda su token
  it('registers the token again for the next user after a sign-out', async () => {
    const { store, wrapper } = setup();
    const { result, rerender } = await renderHook(
      ({ session }: { session: typeof SESSION | null }) => ({ push: usePushRegistration(session), registry: usePushRegistry() }),
      { wrapper, initialProps: { session: SESSION } },
    );
    await act(async () => result.current.registry.store.clear());
    await rerender({ session: null });
    store.save.mockClear();

    await rerender({ session: { userId: 'user-2' } });

    expect(store.save).toHaveBeenCalledWith('ExpoPushToken[fake]');
  });
});

describe('push registry context', () => {
  it('fails clearly when no provider chose a registry', async () => {
    jest.spyOn(console, 'error').mockImplementation(() => undefined);

    await expect(renderHook(() => usePushRegistry())).rejects.toThrow(/PushRegistryProvider/);
  });
});
