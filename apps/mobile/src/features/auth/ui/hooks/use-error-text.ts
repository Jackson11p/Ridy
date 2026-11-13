import { useTranslation } from 'react-i18next';

import type { AuthErrorCode } from '../../domain/auth-error';

export function useErrorText(code: AuthErrorCode | null): string | undefined {
  const { t } = useTranslation();
  return code ? t(`auth.errors.${code}`) : undefined;
}
