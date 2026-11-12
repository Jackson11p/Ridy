import { fireEvent, renderRouter, screen } from 'expo-router/testing-library';

import type { Session } from '@/features/auth';
import { authWrapper } from '@/features/auth/testing/auth-wrapper';
import { createFakeGateway } from '@/features/auth/testing/fake-gateway';
import { i18n } from '@/i18n';

const SESSION: Session = { userId: 'user-1', phone: '+50670000001' };

function renderApp(initialUrl: string, session: Session | null = null) {
  const { gateway } = createFakeGateway(session);
  return renderRouter('./app', { initialUrl, wrapper: authWrapper(gateway) });
}

// fuera de app/: Expo Router trataría el test como una ruta
describe('app routes', () => {
  it('sends a visitor without session from the root to sign-in', async () => {
    const router = await renderApp('/');

    expect(router.getPathname()).toBe('/sign-in');
    expect(screen.getByRole('header', { name: i18n.t('auth.signIn.title') })).toBeTruthy();
  });

  it.each(['/', '/sign-in', '/verify?phone=%2B50670000001'])('sends a signed-in user from %s to /children', async (url) => {
    const router = await renderApp(url, SESSION);

    expect(router.getPathname()).toBe('/children');
    expect(screen.getByRole('header', { name: i18n.t('parent.title') })).toBeTruthy();
  });

  it('signs in end to end: phone, code, then /children', async () => {
    const router = await renderApp('/');

    await fireEvent.changeText(screen.getByLabelText(i18n.t('auth.signIn.phoneLabel')), '70000001');
    await fireEvent.press(screen.getByRole('button', { name: i18n.t('auth.signIn.submit') }));
    await fireEvent.changeText(screen.getByLabelText(i18n.t('auth.verify.codeLabel')), '123456');
    await fireEvent.press(screen.getByRole('button', { name: i18n.t('auth.verify.submit') }));

    expect(router.getPathname()).toBe('/children');
    expect(screen.getByRole('header', { name: i18n.t('parent.title') })).toBeTruthy();
  });

  it.each([
    ['/children', 'parent.title'],
    ['/my-route', 'driver.title'],
    ['/manage', 'manage.title'],
  ])('renders %s', async (url, key) => {
    await renderApp(url, SESSION);

    expect(screen.getByRole('header', { name: i18n.t(key) })).toBeTruthy();
  });
});
