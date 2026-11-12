import { AuthError } from '../domain/auth-error';
import type { AuthGateway, Session } from '../domain/auth-gateway';
import { isValidCode } from '../domain/rules';

export async function verifyCode(gateway: AuthGateway, phone: string, code: string): Promise<Session> {
  if (!isValidCode(code)) throw new AuthError('invalid_code');
  return gateway.verifyCode(phone, code);
}
