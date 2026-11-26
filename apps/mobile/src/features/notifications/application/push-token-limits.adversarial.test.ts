import { createFakePushStore } from '../testing/fake-push';
import { savePushToken } from './register-push-token';

// mismos límites que el check profiles_push_token_format (push-token.adversarial.test.sql)
const accepted = ['ExpoPushToken[' + 'x'.repeat(240) + ']', 'ExponentPushToken[a b]', 'ExpoPushToken[[x]'];
const rejected = [
  'ExpoPushToken[' + 'x'.repeat(241) + ']',
  'ExpoPushToken[]',
  ' ExpoPushToken[a]',
  'ExpoPushToken[a]\n',
  'ExpoPushToken[a]b]',
  'expopushtoken[a]',
  'ExpoPushToken[a',
];

describe('savePushToken limits adversarial', () => {
  it.each(accepted)('saves the boundary token %#', async (token) => {
    const store = createFakePushStore();

    await expect(savePushToken(store, token)).resolves.toBe('registered');
    expect(store.save).toHaveBeenCalledWith(token);
  });

  it.each(rejected)('never sends the invalid token %# to the profile', async (token) => {
    const store = createFakePushStore();

    await expect(savePushToken(store, token)).resolves.toBe('unavailable');
    expect(store.save).not.toHaveBeenCalled();
  });

  it.each([undefined, 42, {}])('treats a non-string token %p as unavailable', async (token) => {
    const store = createFakePushStore();

    await expect(savePushToken(store, token as unknown as string)).resolves.toBe('unavailable');
    expect(store.save).not.toHaveBeenCalled();
  });
});
