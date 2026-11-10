import { render, screen } from '@testing-library/react-native';

import { AppText } from './app-text';
import { darkPalette, lightPalette, typography } from '@/theme';

const mockScheme = jest.fn<'light' | 'dark', []>(() => 'light');
jest.mock('react-native/Libraries/Utilities/useColorScheme', () => ({
  __esModule: true,
  default: () => mockScheme(),
}));

describe('AppText', () => {
  it('defaults to body text in the text tone', async () => {
    await render(<AppText>Hola</AppText>);

    expect(screen.getByText('Hola')).toHaveStyle({ ...typography.body, color: lightPalette.text });
  });

  it.each(Object.keys(typography) as (keyof typeof typography)[])('renders the %s variant', async (variant) => {
    await render(<AppText variant={variant}>Hola</AppText>);

    expect(screen.getByText('Hola')).toHaveStyle(typography[variant]);
  });

  it.each(['muted', 'danger', 'onAction', 'action'] as const)('renders the %s tone', async (tone) => {
    await render(<AppText tone={tone}>Hola</AppText>);

    expect(screen.getByText('Hola')).toHaveStyle({ color: lightPalette[tone] });
  });

  it('uses the dark palette when the system is dark', async () => {
    mockScheme.mockReturnValue('dark');

    await render(<AppText accessibilityRole="header">Hola</AppText>);

    expect(screen.getByRole('header', { name: 'Hola' })).toHaveStyle({ color: darkPalette.text });
  });
});
