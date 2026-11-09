import { StyleSheet, Text } from 'react-native';

import { lightPalette as colors } from '@/theme';

type ScreenTitleProps = { text: string };

export function ScreenTitle({ text }: ScreenTitleProps) {
  return (
    <Text accessibilityRole="header" style={styles.title}>
      {text}
    </Text>
  );
}

const styles = StyleSheet.create({
  title: { fontSize: 24, fontWeight: '600', color: colors.text },
});
