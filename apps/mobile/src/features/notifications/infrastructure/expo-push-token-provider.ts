import Constants from 'expo-constants';
import * as Notifications from 'expo-notifications';
import { Platform } from 'react-native';

import type { PushPermission, PushTokenProvider } from '../domain/push-token';

export type NotificationsModule = Pick<
  typeof Notifications,
  | 'getPermissionsAsync'
  | 'requestPermissionsAsync'
  | 'getExpoPushTokenAsync'
  | 'setNotificationChannelAsync'
  | 'addPushTokenListener'
  | 'AndroidImportance'
>;

type EasConfig = { projectId?: string } | null;
type AppConstants = { expoConfig?: { extra?: { eas?: EasConfig } } | null; easConfig?: EasConfig };

type ProviderDeps = { notifications?: NotificationsModule; platform?: { OS: string }; constants?: AppConstants };

const ANDROID_CHANNEL = 'default';

function projectIdOf(constants: AppConstants): string | undefined {
  return constants.expoConfig?.extra?.eas?.projectId ?? constants.easConfig?.projectId ?? undefined;
}

async function askPermission(notifications: NotificationsModule): Promise<PushPermission> {
  const current = await notifications.getPermissionsAsync();
  const final = current.granted ? current : await notifications.requestPermissionsAsync();
  return final.granted ? 'granted' : 'denied';
}

async function fetchToken(notifications: NotificationsModule, os: string, projectId: string): Promise<string> {
  if (os === 'android') {
    await notifications.setNotificationChannelAsync(ANDROID_CHANNEL, {
      name: ANDROID_CHANNEL,
      importance: notifications.AndroidImportance.DEFAULT,
    });
  }
  const { data } = await notifications.getExpoPushTokenAsync({ projectId });
  return data;
}

// sin push (web, emulador, sin projectId EAS) nunca lanza: 'unavailable' o null
export function createExpoPushTokenProvider({
  notifications = Notifications,
  platform = Platform,
  constants = Constants,
}: ProviderDeps = {}): PushTokenProvider {
  const isWeb = platform.OS === 'web';
  const getToken = async () => {
    const projectId = projectIdOf(constants);
    if (isWeb || !projectId) return null;
    return fetchToken(notifications, platform.OS, projectId).catch(() => null);
  };
  return {
    async requestPermission() {
      if (isWeb) return 'unavailable';
      return askPermission(notifications).catch((): PushPermission => 'unavailable');
    },
    getToken,
    onTokenChange(listener) {
      if (isWeb) return () => undefined;
      const subscription = notifications.addPushTokenListener(() => {
        void getToken().then((token) => token && listener(token));
      });
      return () => subscription.remove();
    },
  };
}
