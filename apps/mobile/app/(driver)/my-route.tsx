import { useTranslation } from 'react-i18next';

import { PlaceholderScreen } from '@/components/placeholder-screen';

export default function DriverHome() {
  const { t } = useTranslation();
  return <PlaceholderScreen title={t('driver.title')} />;
}
