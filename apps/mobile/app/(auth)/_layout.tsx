import { Redirect, Stack } from 'expo-router';

import { useSession } from '@/features/auth';

// con sesión no hay nada que hacer en (auth); /children provisional hasta ATDE-16
export default function AuthLayout() {
  const { loading, session } = useSession();
  if (loading) return null;
  if (session) return <Redirect href="/children" />;
  return <Stack screenOptions={{ headerShown: false }} />;
}
