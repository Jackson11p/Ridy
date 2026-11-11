import { phoneSchema, type Database } from '@ridy/shared';

type ProfileRow = Database['public']['Tables']['profiles']['Row'];

describe('@ridy/shared desde mobile', () => {
  it('resuelve el paquete: esquema de teléfono y tipos de la BD', () => {
    const phone: ProfileRow['phone'] = phoneSchema.parse('506-8888-7777');
    expect(phone).toBe('+50688887777');
  });
});
