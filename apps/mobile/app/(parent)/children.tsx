import { useTranslation } from 'react-i18next';

import { PlaceholderScreen } from '@/components/placeholder-screen';

export default function ParentHome() {
  const { t } = useTranslation();
  return <PlaceholderScreen title={t('parent.title')} />;
}
