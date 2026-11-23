import { useTranslation } from 'react-i18next';

import { TextField } from '@/components/text-field';

import { CODE_LENGTH } from '../domain/rules';

type CodeFieldProps = { value: string; onChangeText: (code: string) => void; onSubmit: () => void; error?: string };

export function CodeField({ value, onChangeText, onSubmit, error }: CodeFieldProps) {
  const { t } = useTranslation();
  return (
    <TextField
      label={t('auth.verify.codeLabel')}
      keyboardType="number-pad"
      textContentType="oneTimeCode"
      autoComplete="sms-otp"
      maxLength={CODE_LENGTH}
      value={value}
      onChangeText={onChangeText}
      onSubmitEditing={onSubmit}
      error={error}
    />
  );
}
