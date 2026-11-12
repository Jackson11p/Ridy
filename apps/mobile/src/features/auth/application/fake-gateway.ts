import type { AuthGateway, Session, SessionListener } from '../domain/auth-gateway';

// doble de pruebas compartido por application, ui y pantallas
export function createFakeGateway(initial: Session | null = null) {
  let session = initial;
  const listeners = new Set<SessionListener>();
  const emit = (next: Session | null) => {
    session = next;
    listeners.forEach((listener) => listener(next));
  };
  const gateway = {
    requestCode: jest.fn<Promise<void>, [string]>(async () => undefined),
    verifyCode: jest.fn<Promise<Session>, [string, string]>(async (phone) => {
      const next = { userId: 'user-1', phone };
      emit(next);
      return next;
    }),
    getSession: jest.fn(async () => session),
    onSessionChange: jest.fn((listener: SessionListener) => {
      listeners.add(listener);
      return () => listeners.delete(listener);
    }),
  } satisfies AuthGateway;
  return { gateway, emit };
}
