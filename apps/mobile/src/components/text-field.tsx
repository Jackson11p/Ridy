import { StyleSheet, TextInput, View, type TextInputProps } from 'react-native';

import { AppText } from './app-text';
import { useTheme, type Theme } from '@/theme';

type TextFieldProps = Omit<TextInputProps, 'editable' | 'accessibilityLabel' | 'accessibilityState'> & {
  label: string;
  error?: string;
  disabled?: boolean;
  prefix?: string;
};

function inputStyle(theme: Theme, hasError: boolean, disabled: boolean) {
  const { colors } = theme;
  return {
    ...theme.typography.body,
    minHeight: theme.sizes.field,
    borderRadius: theme.radius.control,
    borderWidth: theme.borders.control,
    paddingHorizontal: theme.spacing.lg,
    color: disabled ? colors.muted : colors.text,
    backgroundColor: disabled ? colors.disabled : colors.surface,
    borderColor: hasError ? colors.danger : colors.border,
  };
}

export function TextField({ label, error, disabled = false, prefix, style, ...rest }: TextFieldProps) {
  const theme = useTheme();
  const boxStyle = inputStyle(theme, Boolean(error), disabled);
  return (
    <View style={{ gap: theme.spacing.sm }}>
      <AppText variant="label">{label}</AppText>
      <View style={[styles.row, { gap: theme.spacing.sm }]}>
        {prefix ? (
          <View testID="text-field-prefix" style={[boxStyle, styles.prefix]}>
            <AppText>{prefix}</AppText>
          </View>
        ) : null}
        <TextInput
          {...rest}
          accessibilityLabel={label}
          accessibilityState={{ disabled }}
          editable={!disabled}
          placeholderTextColor={theme.colors.muted}
          style={[boxStyle, styles.input, style]}
        />
      </View>
      {error ? (
        <AppText variant="caption" tone="danger" accessibilityRole="alert" accessibilityLiveRegion="polite">
          {error}
        </AppText>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row' },
  prefix: { justifyContent: 'center' },
  input: { flex: 1 },
});
