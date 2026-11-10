import { StyleSheet } from 'react-native';

import { Screen } from './screen';
import { ScreenTitle } from './screen-title';

type PlaceholderScreenProps = { title: string };

export function PlaceholderScreen({ title }: PlaceholderScreenProps) {
  return (
    <Screen contentStyle={styles.centered}>
      <ScreenTitle text={title} />
    </Screen>
  );
}

const styles = StyleSheet.create({ centered: { alignItems: 'center', justifyContent: 'center' } });
