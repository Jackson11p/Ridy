import { resolveLanguage } from './resolve-language';

describe('resolveLanguage', () => {
  it('uses the first supported device language', () => {
    expect(resolveLanguage(['fr', 'en', 'es'])).toBe('en');
  });

  it('falls back to es when no device language is supported', () => {
    expect(resolveLanguage(['fr', 'de'])).toBe('es');
    expect(resolveLanguage([])).toBe('es');
  });
});
