import { Pressable, StyleSheet } from 'react-native';

import { AppText } from './app-text';
import { useTheme } from '@/theme';

type BackHeaderProps = { label: string; onPress: () => void };

const BACK_GLYPH = '‹';

// nombre accesible = texto visible (WCAG 2.5.3); el glifo queda dentro del botón
export function BackHeader({ label, onPress }: BackHeaderProps) {
  const { spacing, sizes } = useTheme();
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={label}
      onPress={onPress}
      style={[styles.row, { gap: spacing.md, minHeight: sizes.touchTarget }]}
    >
      <AppText variant="heading">{BACK_GLYPH}</AppText>
      <AppText variant="heading">{label}</AppText>
    </Pressable>
  );
}

const styles = StyleSheet.create({ row: { flexDirection: 'row', alignItems: 'center' } });
