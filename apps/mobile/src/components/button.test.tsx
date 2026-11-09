import { fireEvent, render, screen } from '@testing-library/react-native';

import { Button } from './button';
import { borders, darkPalette, lightPalette, sizes } from '@/theme';

const mockScheme = jest.fn<'light' | 'dark', []>(() => 'light');
jest.mock('react-native/Libraries/Utilities/useColorScheme', () => ({
  __esModule: true,
  default: () => mockScheme(),
}));

describe('Button', () => {
  it('is an accessible button that calls onPress', async () => {
    const onPress = jest.fn();
    await render(<Button label="Entrar" onPress={onPress} />);

    await fireEvent.press(screen.getByRole('button', { name: 'Entrar' }));

    expect(onPress).toHaveBeenCalledTimes(1);
    expect(screen.getByRole('button')).toHaveStyle({
      height: sizes.button,
      minHeight: sizes.touchTarget,
      backgroundColor: lightPalette.action,
    });
  });

  it.each([
    ['secondary', lightPalette.surface],
    ['danger', lightPalette.dangerAction],
    ['text', 'transparent'],
  ] as const)('renders the %s variant', async (variant, backgroundColor) => {
    await render(<Button label="Entrar" variant={variant} onPress={jest.fn()} />);

    expect(screen.getByRole('button')).toHaveStyle({ backgroundColor });
  });

  it('draws the secondary border with the border token', async () => {
    await render(<Button label="Entrar" variant="secondary" onPress={jest.fn()} />);

    expect(screen.getByRole('button')).toHaveStyle({ borderWidth: borders.control, borderColor: lightPalette.border });
  });

  it('uses the dark palette when the system is dark', async () => {
    mockScheme.mockReturnValueOnce('dark');
    await render(<Button label="Entrar" variant="secondary" onPress={jest.fn()} />);

    expect(screen.getByRole('button')).toHaveStyle({ backgroundColor: darkPalette.surface, borderColor: darkPalette.border });
  });

  it('blocks presses and exposes the disabled state', async () => {
    const onPress = jest.fn();
    await render(<Button label="Entrar" disabled onPress={onPress} />);

    await fireEvent.press(screen.getByRole('button', { name: 'Entrar' }));

    expect(onPress).not.toHaveBeenCalled();
    expect(screen.getByRole('button')).toBeDisabled();
    expect(screen.getByRole('button')).toHaveStyle({ backgroundColor: lightPalette.disabled });
  });

  it('blocks presses and exposes the busy state while loading', async () => {
    const onPress = jest.fn();
    await render(<Button label="Entrar" loading onPress={onPress} />);

    await fireEvent.press(screen.getByRole('button', { name: 'Entrar' }));

    expect(onPress).not.toHaveBeenCalled();
    expect(screen.getByRole('button')).toBeBusy();
    expect(screen.getByTestId('button-spinner')).toBeTruthy();
  });
});
