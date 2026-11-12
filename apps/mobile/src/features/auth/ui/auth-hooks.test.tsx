import { act, renderHook } from '@testing-library/react-native';
import type { ReactNode } from 'react';

import { AuthError } from '../domain/auth-error';
import { createFakeGateway } from '../application/fake-gateway';
import { AuthGatewayProvider } from './auth-gateway-context';
import { useCodeForm } from './use-code-form';
import { usePhoneForm } from './use-phone-form';
import { useSession } from './use-session';

type Fake = ReturnType<typeof createFakeGateway>;

function wrapperFor({ gateway }: Fake) {
  return function Wrapper({ children }: { children: ReactNode }) {
    return <AuthGatewayProvider gateway={gateway}>{children}</AuthGatewayProvider>;
  };
}

describe('useSession', () => {
  it('loads the stored session and follows changes', async () => {
    const fake = createFakeGateway({ userId: 'u', phone: '+50670000001' });
    const { result } = await renderHook(() => useSession(), { wrapper: wrapperFor(fake) });

    expect(result.current).toEqual({ loading: false, session: { userId: 'u', phone: '+50670000001' } });
    await act(async () => fake.emit(null));
    expect(result.current.session).toBeNull();
  });
});

describe('usePhoneForm', () => {
  it('requests the code and reports the normalized phone', async () => {
    const fake = createFakeGateway();
    const onSent = jest.fn();
    const { result } = await renderHook(() => usePhoneForm(onSent), { wrapper: wrapperFor(fake) });

    await act(async () => result.current.setValue('7000 0001'));
    await act(async () => result.current.submit());

    expect(onSent).toHaveBeenCalledWith('+50670000001');
    expect(result.current.error).toBeNull();
  });

  it('exposes the error code and clears it when typing', async () => {
    const fake = createFakeGateway();
    const onSent = jest.fn();
    const { result } = await renderHook(() => usePhoneForm(onSent), { wrapper: wrapperFor(fake) });

    await act(async () => result.current.submit());
    expect(result.current.error).toBe('invalid_phone');
    expect(onSent).not.toHaveBeenCalled();

    await act(async () => result.current.setValue('7'));
    expect(result.current.error).toBeNull();
  });
});

describe('useCodeForm', () => {
  beforeEach(() => jest.useFakeTimers());
  afterEach(() => jest.useRealTimers());

  const render = (fake: Fake, onVerified = jest.fn()) =>
    renderHook(() => useCodeForm('+50670000001', onVerified), { wrapper: wrapperFor(fake) });

  it('verifies the code', async () => {
    const fake = createFakeGateway();
    const onVerified = jest.fn();
    const { result } = await render(fake, onVerified);

    await act(async () => result.current.setCode('123456'));
    await act(async () => result.current.verify());

    expect(fake.gateway.verifyCode).toHaveBeenCalledWith('+50670000001', '123456');
    expect(onVerified).toHaveBeenCalled();
  });

  it('shows invalid_code when the gateway rejects it', async () => {
    const fake = createFakeGateway();
    fake.gateway.verifyCode.mockRejectedValueOnce(new AuthError('invalid_code'));
    const onVerified = jest.fn();
    const { result } = await render(fake, onVerified);

    await act(async () => result.current.setCode('000000'));
    await act(async () => result.current.verify());

    expect(result.current.error).toBe('invalid_code');
    expect(onVerified).not.toHaveBeenCalled();
  });

  it('counts 60 s down before allowing a resend, then restarts it', async () => {
    const fake = createFakeGateway();
    const { result } = await render(fake);

    expect(result.current.secondsLeft).toBe(60);
    await act(async () => jest.advanceTimersByTime(30_000));
    expect(result.current.secondsLeft).toBe(30);
    await act(async () => result.current.resend());
    expect(fake.gateway.requestCode).not.toHaveBeenCalled();

    await act(async () => jest.advanceTimersByTime(30_000));
    expect(result.current.secondsLeft).toBe(0);
    await act(async () => result.current.resend());

    expect(fake.gateway.requestCode).toHaveBeenCalledWith('+50670000001');
    expect(result.current.secondsLeft).toBe(60);
  });
});
