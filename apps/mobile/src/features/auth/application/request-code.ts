import type { Phone } from '@ridy/shared';

import type { AuthGateway } from '../domain/auth-gateway';
import { toCostaRicaPhone } from '../domain/phone';

export async function requestCode(gateway: AuthGateway, typed: string): Promise<Phone> {
  const phone = toCostaRicaPhone(typed);
  await gateway.requestCode(phone);
  return phone;
}
