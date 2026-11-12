import { renderRouter, screen } from 'expo-router/testing-library';

import { i18n } from '@/i18n';

// fuera de app/: Expo Router trataría el test como una ruta
describe('app routes', () => {
  it('redirects the root to sign-in with its translated title', async () => {
    const router = await renderRouter('./app');

    expect(router.getPathname()).toBe('/sign-in');
    expect(screen.getByRole('header', { name: i18n.t('auth.signIn.title') })).toBeTruthy();
  });

  it.each([
    ['/children', 'parent.title'],
    ['/my-route', 'driver.title'],
    ['/manage', 'manage.title'],
  ])('renders %s', async (url, key) => {
    await renderRouter('./app', { initialUrl: url });

    expect(screen.getByRole('header', { name: i18n.t(key) })).toBeTruthy();
  });
});
