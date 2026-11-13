import { phoneSchema, type Phone } from '@ridy/shared';

import { AuthError } from './auth-error';

// beta solo en Costa Rica: prefijo fijo y 8 dígitos locales
const PREFIX = '+506';
const COSTA_RICA = /^\+506\d{8}$/;

// acepta los 8 dígitos o el número ya completo (reenvío y query de verify)
export function parseCostaRicaPhone(typed: string): Phone | null {
  const parsed = phoneSchema.safeParse(typed.trim().startsWith('+') ? typed : `${PREFIX}${typed}`);
  return parsed.success && COSTA_RICA.test(parsed.data) ? parsed.data : null;
}

export function toCostaRicaPhone(typed: string): Phone {
  const phone = parseCostaRicaPhone(typed);
  if (!phone) throw new AuthError('invalid_phone');
  return phone;
}
