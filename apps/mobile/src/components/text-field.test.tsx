import { fireEvent, render, screen } from '@testing-library/react-native';

import { TextField } from './text-field';
import { lightPalette, sizes } from '@/theme';

describe('TextField', () => {
  it('shows its label and forwards input props', async () => {
    const onChangeText = jest.fn();
    await render(<TextField label="Teléfono" onChangeText={onChangeText} />);

    await fireEvent.changeText(screen.getByLabelText('Teléfono'), '3001234567');

    expect(screen.getByText('Teléfono')).toBeTruthy();
    expect(onChangeText).toHaveBeenCalledWith('3001234567');
    expect(screen.getByLabelText('Teléfono')).toHaveStyle({ minHeight: sizes.field, borderColor: lightPalette.border });
  });

  it('announces the error and paints the border danger', async () => {
    await render(<TextField label="Teléfono" error="Número inválido" />);

    expect(screen.getByRole('alert')).toHaveTextContent('Número inválido');
    expect(screen.getByText('Número inválido')).toHaveStyle({ color: lightPalette.danger });
    expect(screen.getByLabelText('Teléfono')).toHaveStyle({ borderColor: lightPalette.danger });
  });

  it('is not editable when disabled', async () => {
    await render(<TextField label="Teléfono" disabled />);

    expect(screen.getByLabelText('Teléfono')).toBeDisabled();
    expect(screen.getByLabelText('Teléfono')).toHaveStyle({ backgroundColor: lightPalette.disabled });
  });
});
