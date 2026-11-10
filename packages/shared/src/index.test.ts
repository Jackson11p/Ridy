import { phoneSchema, type Database, type Phone } from './index';

type RouteRow = Database['public']['Tables']['routes']['Row'];

describe('@ridy/shared', () => {
  it('reexporta el esquema de teléfono y los tipos de la BD', () => {
    const phone: Phone = phoneSchema.parse('+506 8888 7777');
    const code: RouteRow['code'] = 'RDY-ABC234';
    expect([phone, code]).toEqual(['+50688887777', 'RDY-ABC234']);
  });
});
