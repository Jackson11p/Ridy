import { fireEvent, render, screen } from '@testing-library/react-native';

import { BackHeader } from './back-header';
import { sizes, typography } from '@/theme';

describe('BackHeader', () => {
  it('is a button named by its visible text, with the back glyph, that calls onPress', async () => {
    const onPress = jest.fn();
    await render(<BackHeader label="Verificar número" onPress={onPress} />);

    const button = screen.getByRole('button', { name: 'Verificar número' });
    await fireEvent.press(button);

    expect(onPress).toHaveBeenCalledTimes(1);
    expect(screen.getByText('‹')).toBeTruthy();
    expect(screen.getByText('Verificar número')).toHaveStyle(typography.heading);
    expect(button).toHaveStyle({ minHeight: sizes.touchTarget });
  });
});
