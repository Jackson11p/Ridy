import { AuthError } from '../domain/auth-error';
import type { AuthGateway, Session } from '../domain/auth-gateway';
import { toCostaRicaPhone } from '../domain/phone';
import { isValidCode } from '../domain/rules';

export async function verifyCode(gateway: AuthGateway, typed: string, code: string): Promise<Session> {
  const phone = toCostaRicaPhone(typed);
  if (!isValidCode(code)) throw new AuthError('invalid_code');
  return gateway.verifyCode(phone, code);
}
