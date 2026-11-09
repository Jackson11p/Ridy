import { render, screen } from '@testing-library/react-native';

import { AppText } from './app-text';
import { Screen } from './screen';
import { lightPalette, sizes } from '@/theme';

describe('Screen', () => {
  it('paints the theme background with the side gutter', async () => {
    await render(
      <Screen>
        <AppText>Hola</AppText>
      </Screen>,
    );

    expect(screen.getByText('Hola')).toBeTruthy();
    expect(screen.getByTestId('screen')).toHaveStyle({
      backgroundColor: lightPalette.background,
      paddingHorizontal: sizes.screenGutter,
    });
  });

  it('scrolls its content when asked', async () => {
    await render(
      <Screen scroll>
        <AppText>Hola</AppText>
      </Screen>,
    );

    expect(screen.getByTestId('screen-scroll')).toHaveTextContent('Hola');
  });
});
