import { renderHook } from '@testing-library/react-native';

import { darkPalette, lightPalette, radius, sizes, spacing, typography, useTheme } from '@/theme';

const mockScheme = jest.fn<'light' | 'dark' | null, []>(() => 'light');
jest.mock('react-native/Libraries/Utilities/useColorScheme', () => ({
  __esModule: true,
  default: () => mockScheme(),
}));

describe('theme tokens', () => {
  it('matches the Figma light and dark palettes', () => {
    expect(lightPalette).toMatchObject({ background: '#F5F7FB', text: '#10233F', action: '#0962D9', danger: '#B52337' });
    expect(darkPalette).toMatchObject({ background: '#0B1424', text: '#F4F7FC', action: '#0962D9', danger: '#FF8FA1' });
    expect(Object.keys(darkPalette).sort()).toEqual(Object.keys(lightPalette).sort());
  });

  it('exposes typography, spacing, radius and sizes from the prototype', () => {
    expect(typography.display).toEqual({ fontSize: 40, lineHeight: 48, fontWeight: '700' });
    expect(typography.caption).toEqual({ fontSize: 13, lineHeight: 20, fontWeight: '400' });
    expect(spacing).toEqual({ xs: 4, sm: 8, md: 12, lg: 16, xl: 20, xxl: 24, xxxl: 32 });
    expect(radius.control).toBe(14);
    expect(sizes).toMatchObject({ button: 56, touchTarget: 48, screenGutter: 20 });
  });
});

describe('useTheme', () => {
  it.each([
    ['light', lightPalette],
    ['dark', darkPalette],
    [null, lightPalette],
  ] as const)('uses the %s system scheme', async (scheme, palette) => {
    mockScheme.mockReturnValue(scheme);

    const { result } = await renderHook(() => useTheme());

    expect(result.current.colors).toBe(palette);
  });
});
