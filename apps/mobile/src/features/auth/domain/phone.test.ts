import { AuthError } from './auth-error';
import { parseCostaRicaPhone, toCostaRicaPhone } from './phone';

describe('parseCostaRicaPhone', () => {
  it.each([
    ['70000001', '+50670000001'],
    ['8888 0000', '+50688880000'],
    ['+506 8888 0000', '+50688880000'],
  ])('normalizes %s to %s', (typed, phone) => {
    expect(parseCostaRicaPhone(typed)).toBe(phone);
  });

  it.each(['', '8888', '+15551234567', '+506888800001'])('returns null for "%s"', (typed) => {
    expect(parseCostaRicaPhone(typed)).toBeNull();
  });
});

describe('toCostaRicaPhone', () => {
  it('throws invalid_phone for a bad number', () => {
    expect(() => toCostaRicaPhone('123')).toThrow(new AuthError('invalid_phone'));
  });
});
