import { renderHook } from '@testing-library/react-native';

import { useAuthGateway } from './auth-gateway-context';

describe('auth gateway context', () => {
  it('fails clearly when no provider chose a gateway', async () => {
    jest.spyOn(console, 'error').mockImplementation(() => undefined);

    await expect(renderHook(() => useAuthGateway())).rejects.toThrow(/AuthGatewayProvider/);
  });
});
