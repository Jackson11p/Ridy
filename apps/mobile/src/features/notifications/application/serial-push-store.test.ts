import type { ExpoPushToken } from '@ridy/shared';

import { createFakePushStore } from '../testing/fake-push';
import { createSerialPushStore } from './serial-push-store';

const TOKEN = 'ExpoPushToken[a]' as ExpoPushToken;

function deferred() {
  let resolve: () => void = () => undefined;
  const promise = new Promise<void>((done) => (resolve = done));
  return { promise, resolve };
}

describe('createSerialPushStore', () => {
  it('waits for a pending save before clearing', async () => {
    const store = createFakePushStore();
    const pending = deferred();
    store.save.mockReturnValueOnce(pending.promise);
    const serial = createSerialPushStore(store);

    const saving = serial.save(TOKEN);
    const clearing = serial.clear();
    await Promise.resolve();
    expect(store.clear).not.toHaveBeenCalled();

    pending.resolve();
    await Promise.all([saving, clearing]);
    expect(store.clear).toHaveBeenCalled();
  });

  it('drops saves after a clear until it is opened again', async () => {
    const store = createFakePushStore();
    const serial = createSerialPushStore(store);

    await serial.clear();
    await serial.save(TOKEN);
    expect(store.save).not.toHaveBeenCalled();

    serial.open();
    await serial.save(TOKEN);
    expect(store.save).toHaveBeenCalledWith(TOKEN);
  });

  it('keeps the queue going after a failed write and reports the failure', async () => {
    const store = createFakePushStore();
    store.save.mockRejectedValueOnce(new Error('offline'));
    const serial = createSerialPushStore(store);

    await expect(serial.save(TOKEN)).rejects.toThrow('offline');
    await expect(serial.clear()).resolves.toBeUndefined();
    expect(store.clear).toHaveBeenCalled();
  });
});
