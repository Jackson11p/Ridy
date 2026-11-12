import { Redirect } from 'expo-router';

import { useSession } from '@/features/auth';

// /children provisional: ATDE-16 decide la vista por rol
export default function Index() {
  const { loading, session } = useSession();
  if (loading) return null;
  return <Redirect href={session ? '/children' : '/sign-in'} />;
}
