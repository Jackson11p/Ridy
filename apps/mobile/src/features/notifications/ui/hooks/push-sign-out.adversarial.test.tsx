import { act, renderHook } from '@testing-library/react-native';
import type { ReactNode } from 'react';

import { useSession, useSignOut } from '@/features/auth';
import { authWrapper } from '@/features/auth/testing/auth-wrapper';
import { createFakeGateway } from '@/features/auth/testing/fake-gateway';

import { createFakePushProvider, createFakePushStore } from '../../testing/fake-push';
import { pushWrapper } from '../../testing/push-wrapper';
import { useClearPushToken } from './use-clear-push-token';
import { usePushRegistration } from './use-push-registration';

const USER = { userId: 'user-1', phone: '+50670000001' };

// composición como en app/: sesión real del gateway + registro + cerrar sesión con limpieza
function useApp() {
  const { session } = useSession();
  const { status } = usePushRegistration(session);
  const signOut = useSignOut(useClearPushToken());
  return { session, status, signOut };
}

function setup() {
  const { gateway, emit } = createFakeGateway(USER);
  const fake = createFakePushProvider({ token: 'ExpoPushToken[first]' });
  const store = createFakePushStore();
  const Auth = authWrapper(gateway);
  const Push = pushWrapper({ provider: fake.provider, store });
  const wrapper = ({ children }: { children: ReactNode }) => (
    <Auth>
      <Push>{children}</Push>
    </Auth>
  );
  return { gateway, emit, fake, store, wrapper };
}

describe('push + sign-out adversarial', () => {
  it('keeps saving rotated tokens when sign-out fails and the session stays open', async () => {
    const { gateway, fake, store, wrapper } = setup();
    gateway.signOut.mockRejectedValueOnce(new Error('offline'));
    const { result } = await renderHook(() => useApp(), { wrapper });
    expect(result.current.session).not.toBeNull();

    await act(async () => {
      await result.current.signOut().catch(() => undefined);
    });
    expect(result.current.session).not.toBeNull();
    store.save.mockClear();

    await act(async () => fake.emitToken('ExpoPushToken[rotated]'));

    expect(store.save).toHaveBeenCalledWith('ExpoPushToken[rotated]');
  });

  it('registers again when the same user signs back in after sign-out', async () => {
    const { emit, fake, store, wrapper } = setup();
    const { result } = await renderHook(() => useApp(), { wrapper });

    await act(async () => result.current.signOut());
    expect(result.current.session).toBeNull();
    store.save.mockClear();

    await act(async () => emit(USER));
    await act(async () => fake.emitToken('ExpoPushToken[rotated]'));

    expect(store.save).toHaveBeenCalledWith('ExpoPushToken[first]');
    expect(store.save).toHaveBeenCalledWith('ExpoPushToken[rotated]');
    expect(result.current.status).toBe('registered');
  });

  it('still closes the session when clearing the token fails', async () => {
    const { store, wrapper } = setup();
    store.clear.mockRejectedValueOnce(new Error('offline'));
    const { result } = await renderHook(() => useApp(), { wrapper });

    await act(async () => result.current.signOut());

    expect(result.current.session).toBeNull();
  });

  it('does not save a rotation that arrives after the session is gone', async () => {
    const { fake, store, wrapper } = setup();
    const { result } = await renderHook(() => useApp(), { wrapper });

    await act(async () => result.current.signOut());
    store.save.mockClear();
    await act(async () => fake.emitToken('ExpoPushToken[late]'));

    expect(fake.listeners.size).toBe(0);
    expect(store.save).not.toHaveBeenCalled();
  });
});
