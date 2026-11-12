import { render, screen } from '@testing-library/react-native';

import { ScreenIntro } from './screen-intro';
import { lightPalette, typography } from '@/theme';

describe('ScreenIntro', () => {
  it('renders the title as a header and the subtitle muted', async () => {
    await render(<ScreenIntro title="Hola" subtitle="Bienvenido" />);

    expect(screen.getByRole('header', { name: 'Hola' })).toHaveStyle(typography.title);
    expect(screen.getByText('Bienvenido')).toHaveStyle({ color: lightPalette.muted });
  });

  it('omits the subtitle when not given', async () => {
    await render(<ScreenIntro title="Hola" />);

    expect(screen.getByRole('header', { name: 'Hola' })).toBeTruthy();
    expect(screen.queryByText('Bienvenido')).toBeNull();
  });
});
