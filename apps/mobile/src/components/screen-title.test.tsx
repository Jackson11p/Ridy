import { render, screen } from '@testing-library/react-native';

import { ScreenTitle } from './screen-title';
import { lightPalette, typography } from '@/theme';

describe('ScreenTitle', () => {
  it('renders the given text as a display header', async () => {
    await render(<ScreenTitle text="Hola" />);

    expect(screen.getByRole('header', { name: 'Hola' })).toHaveStyle({ ...typography.display, color: lightPalette.text });
  });
});
