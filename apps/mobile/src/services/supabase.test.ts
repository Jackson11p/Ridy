type SupabaseModule = typeof import('./supabase');
// el mock oficial exporta el objeto con module.exports (sin default)
type StorageMock = typeof import('@react-native-async-storage/async-storage').default;

const ENV_KEYS = ['EXPO_PUBLIC_SUPABASE_URL', 'EXPO_PUBLIC_SUPABASE_PUBLISHABLE_KEY'] as const;

function loadFresh() {
  jest.resetModules();
  const { getSupabase } = jest.requireActual<SupabaseModule>('./supabase');
  const storage = jest.requireActual<StorageMock>('@react-native-async-storage/async-storage');
  return { getSupabase, storage };
}

describe('getSupabase', () => {
  const saved = ENV_KEYS.map((key) => process.env[key]);

  afterEach(() => {
    ENV_KEYS.forEach((key, i) => {
      if (saved[i] === undefined) delete process.env[key];
      else process.env[key] = saved[i];
    });
  });

  it('does not create the client on import, and fails clearly without env', () => {
    ENV_KEYS.forEach((key) => delete process.env[key]);

    const { getSupabase } = loadFresh();

    expect(() => getSupabase()).toThrow(/EXPO_PUBLIC_SUPABASE_URL.*apps\/mobile\/\.env\.local/);
  });

  it('creates one client that persists the session in AsyncStorage', async () => {
    process.env.EXPO_PUBLIC_SUPABASE_URL = 'http://127.0.0.1:54321';
    process.env.EXPO_PUBLIC_SUPABASE_PUBLISHABLE_KEY = 'test-key';

    const { getSupabase, storage } = loadFresh();

    expect(getSupabase()).toBe(getSupabase());
    const { data } = await getSupabase().auth.getSession();
    expect(data.session).toBeNull();
    expect(storage.getItem).toHaveBeenCalled();
  });
});
