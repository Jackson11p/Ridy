import type { AuthGateway } from '../domain/auth-gateway';

export type BeforeSignOut = () => Promise<void>;

// best effort: si limpiar falla (p. ej. sin red), igual se cierra la sesión
export async function signOut(gateway: AuthGateway, beforeSignOut: BeforeSignOut): Promise<void> {
  await beforeSignOut().catch(() => undefined);
  await gateway.signOut();
}
