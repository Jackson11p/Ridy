import { render, screen } from '@testing-library/react-native';

import { ScreenTitle } from './screen-title';

describe('ScreenTitle', () => {
  it('renders the given text as a header', async () => {
    await render(<ScreenTitle text="Hola" />);

    expect(screen.getByRole('header', { name: 'Hola' })).toBeTruthy();
  });
});
