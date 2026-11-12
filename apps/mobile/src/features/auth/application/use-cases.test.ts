import { AuthError } from '../domain/auth-error';
import { createFakeGateway } from './fake-gateway';
import { requestCode } from './request-code';
import { verifyCode } from './verify-code';

describe('requestCode', () => {
  it.each([
    ['70000001', '+50670000001'],
    ['8888 0000', '+50688880000'],
    ['8888-0000', '+50688880000'],
  ])('sends %s as %s and returns the normalized phone', async (typed, phone) => {
    const { gateway } = createFakeGateway();

    await expect(requestCode(gateway, typed)).resolves.toBe(phone);
    expect(gateway.requestCode).toHaveBeenCalledWith(phone);
  });

  it.each(['', '8888', '888800001', 'abcdefgh', '+50688880000'])('rejects "%s" without calling the gateway', async (typed) => {
    const { gateway } = createFakeGateway();

    await expect(requestCode(gateway, typed)).rejects.toEqual(new AuthError('invalid_phone'));
    expect(gateway.requestCode).not.toHaveBeenCalled();
  });
});

describe('verifyCode', () => {
  it('verifies a 6-digit code and returns the session', async () => {
    const { gateway } = createFakeGateway();

    await expect(verifyCode(gateway, '+50670000001', '123456')).resolves.toEqual({ userId: 'user-1', phone: '+50670000001' });
    expect(gateway.verifyCode).toHaveBeenCalledWith('+50670000001', '123456');
  });

  it.each(['', '12345', '12a456'])('rejects "%s" without calling the gateway', async (code) => {
    const { gateway } = createFakeGateway();

    await expect(verifyCode(gateway, '+50670000001', code)).rejects.toEqual(new AuthError('invalid_code'));
    expect(gateway.verifyCode).not.toHaveBeenCalled();
  });
});
