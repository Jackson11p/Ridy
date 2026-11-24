import '@/i18n';
import { Stack } from 'expo-router';
import { useState } from 'react';
import { StyleSheet, View } from 'react-native';

import { AuthGatewayProvider, createSupabaseAuthGateway, useSession } from '@/features/auth';
import {
  createExpoPushTokenProvider,
  createSupabasePushTokenStore,
  PushDeniedNotice,
  PushRegistryProvider,
  usePushRegistration,
} from '@/features/notifications';

const createPushRegistry = () => ({ provider: createExpoPushTokenProvider(), store: createSupabasePushTokenStore() });

function PushRegistration() {
  const { session } = useSession();
  const { status } = usePushRegistration(session);
  return <PushDeniedNotice status={status} />;
}

// único punto donde se eligen las implementaciones reales (perezosas: no tocan Supabase ni nativo hasta usarse)
export default function RootLayout() {
  const [gateway] = useState(createSupabaseAuthGateway);
  const [pushRegistry] = useState(createPushRegistry);
  return (
    <AuthGatewayProvider gateway={gateway}>
      <PushRegistryProvider registry={pushRegistry}>
        <View style={styles.fill}>
          <Stack screenOptions={{ headerShown: false }} />
          <PushRegistration />
        </View>
      </PushRegistryProvider>
    </AuthGatewayProvider>
  );
}

const styles = StyleSheet.create({ fill: { flex: 1 } });
