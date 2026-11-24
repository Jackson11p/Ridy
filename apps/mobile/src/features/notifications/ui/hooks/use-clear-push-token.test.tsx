import { renderHook } from '@testing-library/react-native';

import { createFakePushProvider, createFakePushStore } from '../../testing/fake-push';
import { pushWrapper } from '../../testing/push-wrapper';
import { useClearPushToken } from './use-clear-push-token';

describe('useClearPushToken', () => {
  it('returns a function that clears the token of the profile', async () => {
    const store = createFakePushStore();
    const wrapper = pushWrapper({ provider: createFakePushProvider().provider, store });
    const { result } = await renderHook(() => useClearPushToken(), { wrapper });

    await result.current();

    expect(store.clear).toHaveBeenCalled();
  });
});
