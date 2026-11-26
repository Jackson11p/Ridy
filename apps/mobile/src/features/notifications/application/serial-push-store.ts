import type { PushTokenStore } from '../domain/push-token';

export type SerialPushStore = PushTokenStore & { open(): void };

// escrituras en orden: clear espera al save pendiente y, tras borrar, los saves tardíos
// (registro en vuelo, rotación) se descartan hasta que una sesión nueva llame open()
export function createSerialPushStore(store: PushTokenStore): SerialPushStore {
  let tail: Promise<unknown> = Promise.resolve();
  let closed = false;
  const enqueue = (write: () => Promise<void>): Promise<void> => {
    const next = tail.then(write);
    tail = next.catch(() => undefined);
    return next;
  };
  return {
    save: (token) => (closed ? Promise.resolve() : enqueue(() => store.save(token))),
    clear() {
      closed = true;
      return enqueue(() => store.clear());
    },
    open() {
      closed = false;
    },
  };
}
