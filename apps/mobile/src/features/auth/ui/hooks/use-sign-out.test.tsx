import { act, renderHook } from '@testing-library/react-native';

import { authWrapper } from '../../testing/auth-wrapper';
import { createFakeGateway } from '../../testing/fake-gateway';
import { useSession } from './use-session';
import { useSignOut } from './use-sign-out';

describe('useSignOut', () => {
  it('runs the cleanup, closes the session and the app sees no session', async () => {
    const { gateway } = createFakeGateway({ userId: 'user-1', phone: '+50670000001' });
    const clearToken = jest.fn(async () => undefined);
    const { result } = await renderHook(() => ({ signOut: useSignOut(clearToken), state: useSession() }), {
      wrapper: authWrapper(gateway),
    });

    await act(async () => result.current.signOut());

    expect(clearToken).toHaveBeenCalled();
    expect(gateway.signOut).toHaveBeenCalled();
    expect(result.current.state.session).toBeNull();
  });
});
