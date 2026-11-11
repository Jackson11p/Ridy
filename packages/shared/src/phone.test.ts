import { phoneSchema } from './phone';

describe('phoneSchema', () => {
  it.each([
    ['+50688887777', '+50688887777'],
    ['50688887777', '+50688887777'],
    ['  +506 8888-7777 ', '+50688887777'],
    ['+1 (415) 555-2671', '+14155552671'],
    ['+12345678', '+12345678'],
    ['+123456789012345', '+123456789012345'],
  ])('acepta y normaliza %p', (input, expected) => {
    expect(phoneSchema.parse(input)).toBe(expected);
  });

  it.each([
    '',
    '   ',
    '+0123456789',
    '+1234567',
    '+1234567890123456',
    '+506 8888 77a7',
    '++50688887777',
    '+506.8888.7777',
  ])('rechaza %p', (input) => {
    expect(phoneSchema.safeParse(input).success).toBe(false);
  });

  it('rechaza lo que no es texto', () => {
    expect(phoneSchema.safeParse(50688887777).success).toBe(false);
  });
});
