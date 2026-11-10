import { render, screen } from '@testing-library/react-native';

import { AppText } from './app-text';
import { Screen } from './screen';
import { darkPalette, lightPalette, sizes } from '@/theme';

const mockScheme = jest.fn<'light' | 'dark', []>(() => 'light');
jest.mock('react-native/Libraries/Utilities/useColorScheme', () => ({
  __esModule: true,
  default: () => mockScheme(),
}));

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

  it('uses the dark background when the system is dark', async () => {
    mockScheme.mockReturnValueOnce('dark');
    await render(
      <Screen>
        <AppText>Hola</AppText>
      </Screen>,
    );

    expect(screen.getByTestId('screen')).toHaveStyle({ backgroundColor: darkPalette.background });
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
