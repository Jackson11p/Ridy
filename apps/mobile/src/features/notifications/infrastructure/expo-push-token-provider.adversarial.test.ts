import { createExpoPushTokenProvider, type NotificationsModule } from './expo-push-token-provider';

const TOKEN = 'ExpoPushToken[abc]';
const easConstants = { expoConfig: { extra: { eas: { projectId: 'p1' } } } };

function fakeNotifications() {
  let tokenListener: () => void = () => undefined;
  const notifications = {
    getPermissionsAsync: jest.fn(() => Promise.resolve({ granted: true })),
    requestPermissionsAsync: jest.fn(() => Promise.resolve({ granted: true })),
    getExpoPushTokenAsync: jest.fn(() => Promise.resolve({ type: 'expo', data: TOKEN })),
    setNotificationChannelAsync: jest.fn(() => Promise.resolve(null)),
    addPushTokenListener: jest.fn((listener: () => void) => {
      tokenListener = listener;
      return { remove: jest.fn() };
    }),
    AndroidImportance: { DEFAULT: 3 },
  };
  return { notifications, fire: () => tokenListener(), asModule: notifications as unknown as NotificationsModule };
}

function setup(os = 'android', constants: object = easConstants) {
  const fake = fakeNotifications();
  return { ...fake, provider: createExpoPushTokenProvider({ notifications: fake.asModule, platform: { OS: os }, constants }) };
}

const flush = () => new Promise((done) => setTimeout(done, 0));

describe('expoPushTokenProvider adversarial', () => {
  it('reports unavailable when the Android channel cannot be created', async () => {
    const { notifications, provider } = setup();
    notifications.setNotificationChannelAsync.mockRejectedValueOnce(new Error('no channel'));

    await expect(provider.requestPermission()).resolves.toBe('unavailable');
  });

  it('reports unavailable when the permission API throws synchronously', async () => {
    const { notifications, provider } = setup('ios');
    notifications.getPermissionsAsync.mockImplementationOnce(() => {
      throw new Error('native missing');
    });

    await expect(provider.requestPermission()).resolves.toBe('unavailable');
  });

  it('returns null when the Expo token call throws synchronously', async () => {
    const { notifications, provider } = setup('ios');
    notifications.getExpoPushTokenAsync.mockImplementationOnce(() => {
      throw new Error('native missing');
    });

    await expect(provider.getToken()).resolves.toBeNull();
  });

  it('uses easConfig.projectId when expoConfig has none', async () => {
    const { notifications, provider } = setup('ios', { expoConfig: null, easConfig: { projectId: 'p2' } });

    await expect(provider.getToken()).resolves.toBe(TOKEN);
    expect(notifications.getExpoPushTokenAsync).toHaveBeenCalledWith({ projectId: 'p2' });
  });

  it('returns null without asking Expo when projectId is an empty string', async () => {
    const { notifications, provider } = setup('ios', { expoConfig: { extra: { eas: { projectId: '' } } } });

    await expect(provider.getToken()).resolves.toBeNull();
    expect(notifications.getExpoPushTokenAsync).not.toHaveBeenCalled();
  });

  it('does not notify a rotation when fetching the new token fails', async () => {
    const { notifications, provider, fire } = setup('ios');
    const listener = jest.fn();
    provider.onTokenChange(listener);
    notifications.getExpoPushTokenAsync.mockRejectedValueOnce(new Error('offline'));

    fire();
    await flush();

    expect(listener).not.toHaveBeenCalled();
  });
});
