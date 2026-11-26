import { expoPushTokenSchema } from './index';

describe('expoPushTokenSchema', () => {
  it.each(['ExpoPushToken[xxxxxxxxxxxxxxxxxxxxxx]', 'ExponentPushToken[abc-123_X]'])('acepta %p', (token) => {
    expect(expoPushTokenSchema.parse(token)).toBe(token);
  });

  it.each([
    '',
    'tok',
    'ExpoPushToken[]',
    'ExpoPushToken[a]b',
    'ExpoPushToken[a]]',
    'xExpoPushToken[a]',
    'FcmToken[a]',
    `ExpoPushToken[${'x'.repeat(241)}]`,
  ])('rechaza %p', (token) => {
    expect(expoPushTokenSchema.safeParse(token).success).toBe(false);
  });

  it('acepta justo 255 caracteres', () => {
    const token = `ExpoPushToken[${'x'.repeat(240)}]`;
    expect(token).toHaveLength(255);
    expect(expoPushTokenSchema.safeParse(token).success).toBe(true);
  });

  it('rechaza lo que no es texto', () => {
    expect(expoPushTokenSchema.safeParse(null).success).toBe(false);
  });
});
