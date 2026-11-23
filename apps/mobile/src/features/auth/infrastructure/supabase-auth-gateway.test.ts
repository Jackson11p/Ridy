import { AuthApiError, type Session as SupabaseSession } from '@supabase/supabase-js';

import { AuthError } from '../domain/auth-error';
import { createSupabaseAuthGateway, type SupabaseAuth } from './supabase-auth-gateway';

const supabaseSession = { user: { id: 'user-1', phone: '50670000001' } } as SupabaseSession;
type Result = Promise<{ data: { session: SupabaseSession | null }; error: AuthApiError | null }>;
const ok = (session: SupabaseSession | null): Result => Promise.resolve({ data: { session }, error: null });
const fail = (code: string): Result => Promise.resolve({ data: { session: null }, error: new AuthApiError(code, 400, code) });

function fakeAuth() {
  const unsubscribe = jest.fn();
  const auth = {
    signInWithOtp: jest.fn(() => ok(null)),
    verifyOtp: jest.fn(() => ok(supabaseSession)),
    getSession: jest.fn(() => ok(supabaseSession)),
    onAuthStateChange: jest.fn((_cb: (event: string, session: SupabaseSession | null) => void) => ({
      data: { subscription: { unsubscribe } },
    })),
  };
  return { auth, unsubscribe, gateway: createSupabaseAuthGateway(() => auth as unknown as SupabaseAuth) };
}

describe('supabaseAuthGateway', () => {
  it('requests the code by SMS channel (the send hook delivers it by WhatsApp)', async () => {
    const { auth, gateway } = fakeAuth();

    await gateway.requestCode('+50670000001');

    expect(auth.signInWithOtp).toHaveBeenCalledWith({ phone: '+50670000001' });
  });

  it('verifies the code and maps the session', async () => {
    const { auth, gateway } = fakeAuth();

    await expect(gateway.verifyCode('+50670000001', '123456')).resolves.toEqual({ userId: 'user-1', phone: '+50670000001' });
    expect(auth.verifyOtp).toHaveBeenCalledWith({ phone: '+50670000001', token: '123456', type: 'sms' });
  });

  it.each([
    ['otp_expired', 'invalid_code'],
    ['invalid_credentials', 'invalid_code'],
    ['over_sms_send_rate_limit', 'too_soon'],
    ['over_request_rate_limit', 'too_soon'],
    ['validation_failed', 'invalid_phone'],
    ['sms_send_failed', 'unknown'],
  ])('maps the Supabase error %s to %s', async (supabaseCode, domainCode) => {
    const { auth, gateway } = fakeAuth();
    auth.signInWithOtp.mockReturnValueOnce(fail(supabaseCode));
    auth.verifyOtp.mockReturnValueOnce(fail(supabaseCode));

    await expect(gateway.requestCode('+50670000001')).rejects.toEqual(new AuthError(domainCode as AuthError['code']));
    await expect(gateway.verifyCode('+50670000001', '123456')).rejects.toEqual(new AuthError(domainCode as AuthError['code']));
  });

  it('fails as unknown when verify returns no session', async () => {
    const { auth, gateway } = fakeAuth();
    auth.verifyOtp.mockReturnValueOnce(ok(null));

    await expect(gateway.verifyCode('+50670000001', '123456')).rejects.toEqual(new AuthError('unknown'));
  });

  it('reads the stored session', async () => {
    const { auth, gateway } = fakeAuth();

    await expect(gateway.getSession()).resolves.toEqual({ userId: 'user-1', phone: '+50670000001' });
    auth.getSession.mockReturnValueOnce(ok(null));
    await expect(gateway.getSession()).resolves.toBeNull();
  });

  it('forwards session changes and unsubscribes', () => {
    const { auth, unsubscribe, gateway } = fakeAuth();
    const listener = jest.fn();

    const stop = gateway.onSessionChange(listener);
    const callback = auth.onAuthStateChange.mock.calls[0][0];
    callback('SIGNED_IN', supabaseSession);
    callback('SIGNED_OUT', null);
    stop();

    expect(listener.mock.calls).toEqual([[{ userId: 'user-1', phone: '+50670000001' }], [null]]);
    expect(unsubscribe).toHaveBeenCalled();
  });
});
