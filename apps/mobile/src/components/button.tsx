import { ActivityIndicator, Pressable, StyleSheet } from 'react-native';

import { AppText, type AppTextTone } from './app-text';
import { useTheme, type Palette, type Theme } from '@/theme';

export type ButtonVariant = 'primary' | 'secondary' | 'danger' | 'text';

type ButtonProps = {
  label: string;
  onPress: () => void;
  variant?: ButtonVariant;
  disabled?: boolean;
  loading?: boolean;
};

type VariantColors = { background: keyof Palette | 'transparent'; border?: keyof Palette; tone: AppTextTone };

const VARIANTS: Record<ButtonVariant, VariantColors> = {
  primary: { background: 'action', tone: 'onAction' },
  secondary: { background: 'surface', border: 'border', tone: 'action' },
  danger: { background: 'dangerAction', tone: 'onAction' },
  text: { background: 'transparent', tone: 'action' },
};

const DISABLED: VariantColors = { background: 'disabled', tone: 'muted' };

function resolveColors(variant: ButtonVariant, disabled: boolean): VariantColors {
  if (!disabled) return VARIANTS[variant];
  return variant === 'text' ? { ...VARIANTS.text, tone: 'muted' } : DISABLED;
}

function containerStyle(theme: Theme, colors: VariantColors) {
  const pick = (key: keyof Palette | 'transparent') => (key === 'transparent' ? key : theme.colors[key]);
  return {
    height: theme.sizes.button,
    minHeight: theme.sizes.touchTarget,
    borderRadius: theme.radius.control,
    paddingHorizontal: theme.spacing.xxl,
    backgroundColor: pick(colors.background),
    borderColor: colors.border ? theme.colors[colors.border] : 'transparent',
    borderWidth: colors.border ? theme.borders.control : 0,
  };
}

export function Button({ label, onPress, variant = 'primary', disabled = false, loading = false }: ButtonProps) {
  const theme = useTheme();
  const blocked = disabled || loading;
  const colors = resolveColors(variant, disabled);
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={label}
      accessibilityState={{ disabled: blocked, busy: loading }}
      disabled={blocked}
      onPress={blocked ? undefined : onPress}
      style={[styles.base, containerStyle(theme, colors)]}
    >
      {loading ? (
        <ActivityIndicator testID="button-spinner" color={theme.colors[colors.tone]} />
      ) : (
        <AppText variant="button" tone={colors.tone}>
          {label}
        </AppText>
      )}
    </Pressable>
  );
}

const styles = StyleSheet.create({ base: { alignItems: 'center', justifyContent: 'center' } });
