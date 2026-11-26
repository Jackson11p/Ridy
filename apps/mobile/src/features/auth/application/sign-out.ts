import type { AuthGateway } from '../domain/auth-gateway';

// la limpieza puede devolver cómo deshacerse si la sesión no llega a cerrarse
export type BeforeSignOut = () => Promise<(() => void) | void>;

// best effort: si limpiar falla (p. ej. sin red), igual se cierra la sesión
export async function signOut(gateway: AuthGateway, beforeSignOut: BeforeSignOut): Promise<void> {
  const undo = await beforeSignOut().catch(() => undefined);
  try {
    await gateway.signOut();
  } catch (error) {
    undo?.();
    throw error;
  }
}
