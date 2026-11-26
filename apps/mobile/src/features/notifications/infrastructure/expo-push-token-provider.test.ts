import { createExpoPushTokenProvider, type NotificationsModule } from './expo-push-token-provider';

const PROJECT_ID = 'eas-project-1';
const TOKEN = 'ExponentPushToken[abc123]';
const easConstants = { expoConfig: { extra: { eas: { projectId: PROJECT_ID } } } };

function permission(granted: boolean) {
  return Promise.resolve({ granted, status: granted ? 'granted' : 'denied', canAskAgain: true, expires: 'never' });
}

function fakeNotifications() {
  const remove = jest.fn();
  const notifications = {
    getPermissionsAsync: jest.fn(() => permission(false)),
    requestPermissionsAsync: jest.fn(() => permission(true)),
    getExpoPushTokenAsync: jest.fn(() => Promise.resolve({ type: 'expo', data: TOKEN })),
    setNotificationChannelAsync: jest.fn(() => Promise.resolve(null)),
    addPushTokenListener: jest.fn((_listener: () => void) => ({ remove })),
    AndroidImportance: { DEFAULT: 5 },
  };
  return { notifications, remove, asModule: notifications as unknown as NotificationsModule };
}

function setup(os: 'ios' | 'android' | 'web' = 'ios', constants: object = easConstants) {
  const fake = fakeNotifications();
  const provider = createExpoPushTokenProvider({ notifications: fake.asModule, platform: { OS: os }, constants });
  return { ...fake, provider };
}

describe('expoPushTokenProvider permission', () => {
  it('asks the user when not granted yet', async () => {
    const { notifications, provider } = setup();

    await expect(provider.requestPermission()).resolves.toBe('granted');
    expect(notifications.requestPermissionsAsync).toHaveBeenCalled();
  });

  it('does not ask again when already granted', async () => {
    const { notifications, provider } = setup();
    notifications.getPermissionsAsync.mockReturnValueOnce(permission(true));

    await expect(provider.requestPermission()).resolves.toBe('granted');
    expect(notifications.requestPermissionsAsync).not.toHaveBeenCalled();
  });

  it('reports denied when the user refuses', async () => {
    const { notifications, provider } = setup();
    notifications.requestPermissionsAsync.mockReturnValueOnce(permission(false));

    await expect(provider.requestPermission()).resolves.toBe('denied');
  });

  // Android 13+: sin canal el sistema no muestra el diálogo de permiso
  it('creates the Android default channel before checking or asking permission', async () => {
    const { notifications, provider } = setup('android');

    await expect(provider.requestPermission()).resolves.toBe('granted');
    expect(notifications.setNotificationChannelAsync).toHaveBeenCalledWith('default', expect.objectContaining({ importance: 5 }));
    const channelOrder = notifications.setNotificationChannelAsync.mock.invocationCallOrder[0];
    expect(channelOrder).toBeLessThan(notifications.getPermissionsAsync.mock.invocationCallOrder[0]);
  });

  it('does not create a channel on iOS', async () => {
    const { notifications, provider } = setup('ios');

    await provider.requestPermission();

    expect(notifications.setNotificationChannelAsync).not.toHaveBeenCalled();
  });

  it('reports unavailable on web and when the module fails', async () => {
    await expect(setup('web').provider.requestPermission()).resolves.toBe('unavailable');
    const { notifications, provider } = setup();
    notifications.getPermissionsAsync.mockRejectedValueOnce(new Error('no module'));
    await expect(provider.requestPermission()).resolves.toBe('unavailable');
  });
});

describe('expoPushTokenProvider token', () => {
  it('gets the Expo token with the EAS projectId', async () => {
    const { notifications, provider } = setup('ios');

    await expect(provider.getToken()).resolves.toBe(TOKEN);
    expect(notifications.getExpoPushTokenAsync).toHaveBeenCalledWith({ projectId: PROJECT_ID });
    expect(notifications.setNotificationChannelAsync).not.toHaveBeenCalled();
  });

  it('gets the token on Android with the projectId from easConfig', async () => {
    const { notifications, provider } = setup('android', { easConfig: { projectId: PROJECT_ID } });

    await expect(provider.getToken()).resolves.toBe(TOKEN);
    expect(notifications.getExpoPushTokenAsync).toHaveBeenCalledWith({ projectId: PROJECT_ID });
  });

  it('returns null on web, without projectId or when the device has no push', async () => {
    await expect(setup('web').provider.getToken()).resolves.toBeNull();
    await expect(setup('ios', {}).provider.getToken()).resolves.toBeNull();
    const { notifications, provider } = setup();
    notifications.getExpoPushTokenAsync.mockRejectedValueOnce(new Error('simulator'));
    await expect(provider.getToken()).resolves.toBeNull();
  });
});

describe('expoPushTokenProvider token changes', () => {
  it('re-reads the Expo token when the device token rotates and unsubscribes', async () => {
    const { notifications, remove, provider } = setup();
    const listener = jest.fn();

    const stop = provider.onTokenChange(listener);
    notifications.getExpoPushTokenAsync.mockResolvedValueOnce({ type: 'expo', data: 'ExpoPushToken[new]' });
    notifications.addPushTokenListener.mock.calls[0][0]();
    await new Promise(process.nextTick);
    stop();

    expect(listener).toHaveBeenCalledWith('ExpoPushToken[new]');
    expect(remove).toHaveBeenCalled();
  });

  // contrato de domain: infrastructure no lanza; sin módulo nativo no hay rotaciones
  it('does not throw when subscribing to token changes fails natively', () => {
    const { notifications, provider } = setup('ios');
    notifications.addPushTokenListener.mockImplementationOnce(() => {
      throw new Error('native missing');
    });

    expect(() => provider.onTokenChange(jest.fn())()).not.toThrow();
  });

  it('does not listen on web', () => {
    const { notifications, provider } = setup('web');

    provider.onTokenChange(jest.fn())();

    expect(notifications.addPushTokenListener).not.toHaveBeenCalled();
  });
});
