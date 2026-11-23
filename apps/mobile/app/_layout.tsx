import '@/i18n';
import { Stack } from 'expo-router';
import { useState } from 'react';

import { AuthGatewayProvider, createSupabaseAuthGateway } from '@/features/auth';

// único punto donde se elige el gateway real (perezoso: no toca Supabase hasta usarse)
export default function RootLayout() {
  const [gateway] = useState(createSupabaseAuthGateway);
  return (
    <AuthGatewayProvider gateway={gateway}>
      <Stack screenOptions={{ headerShown: false }} />
    </AuthGatewayProvider>
  );
}
