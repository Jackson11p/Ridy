import { fireEvent, renderRouter, screen } from 'expo-router/testing-library';

import type { AuthGateway, Session } from '@/features/auth';
import { createFakeGateway } from '@/features/auth/testing/fake-gateway';
import type { PushPermission, PushTokenProvider, PushTokenStore } from '@/features/notifications';
import { createFakePushProvider, createFakePushStore } from '@/features/notifications/testing/fake-push';
import { i18n } from '@/i18n';

const SESSION: Session = { userId: 'user-1', phone: '+50670000001' };

// app/_layout.tsx monta el gateway real: aquí la fábrica devuelve el falso del test
const mockGateway: { current?: AuthGateway } = {};
jest.mock('@/features/auth/infrastructure/supabase-auth-gateway', () => ({
  createSupabaseAuthGateway: () => mockGateway.current,
}));

// igual con notificaciones: nunca se llama nativo ni Supabase
const mockPush: { provider?: PushTokenProvider; store?: PushTokenStore } = {};
jest.mock('@/features/notifications/infrastructure/expo-push-token-provider', () => ({
  createExpoPushTokenProvider: () => mockPush.provider,
}));
jest.mock('@/features/notifications/infrastructure/supabase-push-token-store', () => ({
  createSupabasePushTokenStore: () => mockPush.store,
}));

function renderApp(initialUrl: string, session: Session | null = null, permission: PushPermission = 'granted') {
  mockGateway.current = createFakeGateway(session).gateway;
  mockPush.provider = createFakePushProvider({ permission }).provider;
  mockPush.store = createFakePushStore();
  return renderRouter('./app', { initialUrl });
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

  it('registers the push token of a signed-in user without showing the notice', async () => {
    await renderApp('/children', SESSION);

    expect(mockPush.store?.save).toHaveBeenCalledWith('ExpoPushToken[fake]');
    expect(screen.queryByText(i18n.t('notifications.denied'))).toBeNull();
  });

  it('keeps working and shows the notice when push permission is denied', async () => {
    await renderApp('/children', SESSION, 'denied');

    expect(screen.getByRole('header', { name: i18n.t('parent.title') })).toBeTruthy();
    expect(screen.getByText(i18n.t('notifications.denied'))).toBeTruthy();
  });

  it('does not ask for push permission without a session', async () => {
    await renderApp('/');

    expect(mockPush.provider?.requestPermission).not.toHaveBeenCalled();
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
