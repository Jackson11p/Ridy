import { phoneSchema, type Phone } from '@ridy/shared';

import { AuthError } from '../domain/auth-error';
import type { AuthGateway } from '../domain/auth-gateway';

// beta solo en Costa Rica: prefijo fijo y 8 dígitos locales
const PREFIX = '+506';
const COSTA_RICA = /^\+506\d{8}$/;

// acepta los 8 dígitos o el número ya completo (reenvío desde verify)
function toCostaRicaPhone(typed: string): Phone {
  const parsed = phoneSchema.safeParse(typed.trim().startsWith('+') ? typed : `${PREFIX}${typed}`);
  if (!parsed.success || !COSTA_RICA.test(parsed.data)) throw new AuthError('invalid_phone');
  return parsed.data;
}

export async function requestCode(gateway: AuthGateway, typed: string): Promise<Phone> {
  const phone = toCostaRicaPhone(typed);
  await gateway.requestCode(phone);
  return phone;
}
