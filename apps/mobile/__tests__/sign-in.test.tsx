import { fireEvent, renderRouter, screen } from 'expo-router/testing-library';

import SignIn from '../app/(auth)/sign-in';
import { authWrapper } from '@/features/auth/testing/auth-wrapper';
import { createFakeGateway } from '@/features/auth/testing/fake-gateway';
import { i18n } from '@/i18n';

const t = (key: string) => i18n.t(key);

async function renderSignIn() {
  const fake = createFakeGateway();
  const routes = { '(auth)/sign-in': SignIn, '(auth)/verify': () => null };
  const router = await renderRouter(routes, { initialUrl: '/sign-in', wrapper: authWrapper(fake.gateway) });
  return { ...fake, router };
}

describe('sign-in screen (A01)', () => {
  it('renders the A01 copy without SMS', async () => {
    await renderSignIn();

    expect(screen.getByText(t('auth.signIn.welcome'))).toBeTruthy();
    expect(screen.getByRole('header', { name: t('auth.signIn.title') })).toBeTruthy();
    expect(screen.getByText(t('auth.signIn.subtitle'))).toBeTruthy();
    expect(screen.getByText(t('auth.signIn.prefix'))).toBeTruthy();
    expect(screen.getByLabelText(t('auth.signIn.phoneLabel'))).toBeTruthy();
    expect(screen.getByRole('button', { name: t('auth.signIn.submit') })).toBeTruthy();
    expect(screen.getByText(t('auth.signIn.legal'))).toBeTruthy();
    expect(screen.queryByText(/SMS/)).toBeNull();
  });

  it('shows the field error and requests nothing for an invalid number', async () => {
    const { gateway } = await renderSignIn();

    await fireEvent.changeText(screen.getByLabelText(t('auth.signIn.phoneLabel')), '8888');
    await fireEvent.press(screen.getByRole('button', { name: t('auth.signIn.submit') }));

    expect(screen.getByRole('alert')).toHaveTextContent(t('auth.errors.invalid_phone'));
    expect(gateway.requestCode).not.toHaveBeenCalled();
  });

  it('requests the code and goes to verify with the normalized phone', async () => {
    const { gateway, router } = await renderSignIn();

    await fireEvent.changeText(screen.getByLabelText(t('auth.signIn.phoneLabel')), '7000 0001');
    await fireEvent.press(screen.getByRole('button', { name: t('auth.signIn.submit') }));

    expect(gateway.requestCode).toHaveBeenCalledWith('+50670000001');
    expect(router.getPathname()).toBe('/verify');
    expect(router.getSearchParams()).toEqual({ phone: '+50670000001' });
  });

  it('has the same keys in Spanish and English', () => {
    const keys = (lng: string) => Object.keys(i18n.getResourceBundle(lng, 'translation').auth.signIn).sort();

    expect(keys('en')).toEqual(keys('es'));
  });
});
