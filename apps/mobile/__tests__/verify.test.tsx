import { act, fireEvent, renderRouter, screen } from 'expo-router/testing-library';

import Verify from '../app/(auth)/verify';
import { AuthError } from '@/features/auth/domain/auth-error';
import { authWrapper } from '@/features/auth/testing/auth-wrapper';
import { createFakeGateway } from '@/features/auth/testing/fake-gateway';
import { i18n } from '@/i18n';

const t = (key: string, options?: Record<string, string>) => i18n.t(key, options);
const routes = { '(auth)/verify': Verify, '(auth)/sign-in': () => null, '(parent)/children': () => null };

async function renderVerify() {
  const fake = createFakeGateway();
  const router = await renderRouter(routes, { initialUrl: '/verify?phone=%2B50670000001', wrapper: authWrapper(fake.gateway) });
  return { ...fake, router };
}

const codeField = () => screen.getByLabelText(t('auth.verify.codeLabel'));
const button = (key: string) => screen.getByRole('button', { name: t(key) });

describe('verify screen (A02/A03)', () => {
  beforeEach(() => jest.useFakeTimers());
  afterEach(() => jest.useRealTimers());

  it('renders the A02 copy with the formatted phone and the countdown, without SMS', async () => {
    await renderVerify();

    expect(button('auth.verify.back')).toBeTruthy();
    expect(screen.getByRole('header', { name: t('auth.verify.title') })).toBeTruthy();
    expect(screen.getByText(t('auth.verify.sentTo', { phone: '+506 7000 0001' }))).toBeTruthy();
    expect(button('auth.verify.submit')).toBeTruthy();
    expect(screen.getByText(t('auth.verify.resendIn', { time: '01:00' }))).toBeTruthy();
    expect(screen.queryByRole('button', { name: t('auth.verify.resend') })).toBeNull();
    expect(button('auth.verify.changePhone')).toBeTruthy();
    expect(screen.queryByText(/SMS/)).toBeNull();
  });

  it('enters with the right code and goes to /children', async () => {
    const { gateway, router } = await renderVerify();

    await fireEvent.changeText(codeField(), '123456');
    await fireEvent.press(button('auth.verify.submit'));

    expect(gateway.verifyCode).toHaveBeenCalledWith('+50670000001', '123456');
    expect(router.getPathname()).toBe('/children');
  });

  it('shows the A03 error for a wrong or expired code and stays', async () => {
    const { gateway, router } = await renderVerify();
    gateway.verifyCode.mockRejectedValueOnce(new AuthError('invalid_code'));

    await fireEvent.changeText(codeField(), '000000');
    await fireEvent.press(button('auth.verify.submit'));

    expect(screen.getByRole('header', { name: t('auth.verify.retryTitle') })).toBeTruthy();
    expect(screen.getByRole('alert')).toHaveTextContent(t('auth.errors.invalid_code'));
    expect(router.getPathname()).toBe('/verify');
  });

  it('lets the user request another code only after 60 s', async () => {
    const { gateway } = await renderVerify();

    await act(async () => jest.advanceTimersByTime(59_000));
    expect(screen.getByText(t('auth.verify.resendIn', { time: '00:01' }))).toBeTruthy();
    await act(async () => jest.advanceTimersByTime(1_000));
    await fireEvent.press(button('auth.verify.resend'));

    expect(gateway.requestCode).toHaveBeenCalledWith('+50670000001');
    expect(screen.getByText(t('auth.verify.resendIn', { time: '01:00' }))).toBeTruthy();
  });

  it.each(['auth.verify.changePhone', 'auth.verify.back'])('%s goes back to sign-in', async (key) => {
    const { router } = await renderVerify();

    await fireEvent.press(button(key));

    expect(router.getPathname()).toBe('/sign-in');
  });

  it('has the same keys in Spanish and English', () => {
    const keys = (lng: string) => Object.keys(i18n.getResourceBundle(lng, 'translation').auth.verify).sort();

    expect(keys('en')).toEqual(keys('es'));
  });
});
