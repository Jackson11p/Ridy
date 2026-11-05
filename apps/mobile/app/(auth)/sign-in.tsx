import { useTranslation } from 'react-i18next';

import { PlaceholderScreen } from '@/components/placeholder-screen';

export default function AuthHome() {
  const { t } = useTranslation();
  return <PlaceholderScreen title={t('auth.title')} />;
}
