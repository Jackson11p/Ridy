import { Redirect } from 'expo-router';

// shortcut: siempre a (auth); la vista por rol llega con ATDE-15
export default function Index() {
  return <Redirect href="/sign-in" />;
}
