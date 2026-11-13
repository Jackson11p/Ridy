import type { Phone } from '@ridy/shared';

export type Session = { userId: string; phone: string };

export type SessionListener = (session: Session | null) => void;

// I/O de autenticación; infrastructure lo implementa y lanza AuthError
export interface AuthGateway {
  requestCode(phone: Phone): Promise<void>;
  verifyCode(phone: Phone, code: string): Promise<Session>;
  getSession(): Promise<Session | null>;
  onSessionChange(listener: SessionListener): () => void;
}
