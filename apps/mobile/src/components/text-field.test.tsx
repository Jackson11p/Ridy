import { fireEvent, render, screen } from '@testing-library/react-native';

import { TextField } from './text-field';
import { borders, darkPalette, lightPalette, sizes } from '@/theme';

const mockScheme = jest.fn<'light' | 'dark', []>(() => 'light');
jest.mock('react-native/Libraries/Utilities/useColorScheme', () => ({
  __esModule: true,
  default: () => mockScheme(),
}));

describe('TextField', () => {
  it('shows its label and forwards input props', async () => {
    const onChangeText = jest.fn();
    await render(<TextField label="Teléfono" onChangeText={onChangeText} />);

    await fireEvent.changeText(screen.getByLabelText('Teléfono'), '3001234567');

    expect(screen.getByText('Teléfono')).toBeTruthy();
    expect(onChangeText).toHaveBeenCalledWith('3001234567');
    expect(screen.getByLabelText('Teléfono')).toHaveStyle({
      minHeight: sizes.field,
      borderWidth: borders.control,
      borderColor: lightPalette.border,
    });
  });

  it('announces the error and paints the border danger', async () => {
    await render(<TextField label="Teléfono" error="Número inválido" />);

    expect(screen.getByRole('alert')).toHaveTextContent('Número inválido');
    expect(screen.getByText('Número inválido')).toHaveStyle({ color: lightPalette.danger });
    expect(screen.getByLabelText('Teléfono')).toHaveStyle({ borderColor: lightPalette.danger });
  });

  it('uses the dark palette when the system is dark', async () => {
    mockScheme.mockReturnValueOnce('dark');
    await render(<TextField label="Teléfono" />);

    expect(screen.getByLabelText('Teléfono')).toHaveStyle({
      backgroundColor: darkPalette.surface,
      borderColor: darkPalette.border,
      color: darkPalette.text,
    });
  });

  it('shows a fixed prefix box before the input', async () => {
    await render(<TextField label="Teléfono" prefix="CR +506" />);

    expect(screen.getByText('CR +506')).toBeTruthy();
    expect(screen.getByTestId('text-field-prefix')).toHaveStyle({ minHeight: sizes.field, borderColor: lightPalette.border });
  });

  it('is not editable when disabled', async () => {
    await render(<TextField label="Teléfono" disabled />);

    expect(screen.getByLabelText('Teléfono')).toBeDisabled();
    expect(screen.getByLabelText('Teléfono')).toHaveStyle({ backgroundColor: lightPalette.disabled });
  });
});
