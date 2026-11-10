import type { ReactNode } from 'react';
import { ScrollView, StyleSheet, type StyleProp, type ViewStyle } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { useTheme } from '@/theme';

type ScreenProps = { children: ReactNode; scroll?: boolean; contentStyle?: StyleProp<ViewStyle> };

export function Screen({ children, scroll = false, contentStyle }: ScreenProps) {
  const theme = useTheme();
  const frame = { backgroundColor: theme.colors.background, paddingHorizontal: theme.sizes.screenGutter };
  if (!scroll) {
    return (
      <SafeAreaView testID="screen" style={[styles.fill, frame, contentStyle]}>
        {children}
      </SafeAreaView>
    );
  }
  return (
    <SafeAreaView testID="screen" style={[styles.fill, frame]}>
      <ScrollView testID="screen-scroll" contentContainerStyle={contentStyle}>
        {children}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({ fill: { flex: 1 } });
