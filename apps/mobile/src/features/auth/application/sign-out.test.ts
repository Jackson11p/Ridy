import { createFakeGateway } from '../testing/fake-gateway';
import { signOut } from './sign-out';

describe('signOut', () => {
  it('clears the push token before closing the session', async () => {
    const { gateway } = createFakeGateway({ userId: 'user-1', phone: '+50670000001' });
    const clearToken = jest.fn(async () => undefined);

    await signOut(gateway, clearToken);

    expect(clearToken).toHaveBeenCalled();
    expect(gateway.signOut).toHaveBeenCalled();
    expect(clearToken.mock.invocationCallOrder[0]).toBeLessThan(gateway.signOut.mock.invocationCallOrder[0]);
  });

  it('still closes the session when clearing the token fails', async () => {
    const { gateway } = createFakeGateway({ userId: 'user-1', phone: '+50670000001' });

    await signOut(gateway, () => Promise.reject(new Error('offline')));

    expect(gateway.signOut).toHaveBeenCalled();
  });

  it('lets a sign out failure reach the caller', async () => {
    const { gateway } = createFakeGateway();
    gateway.signOut.mockRejectedValueOnce(new Error('offline'));

    await expect(signOut(gateway, async () => undefined)).rejects.toThrow('offline');
  });
});
