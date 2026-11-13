import type { AuthError as SupabaseAuthError, Session as SupabaseSession, SupabaseClient } from '@supabase/supabase-js';

import { getSupabase } from '@/services/supabase';

import { AuthError, type AuthErrorCode } from '../domain/auth-error';
import type { AuthGateway, Session } from '../domain/auth-gateway';

export type SupabaseAuth = SupabaseClient['auth'];

const ERROR_CODES: Record<string, AuthErrorCode> = {
  otp_expired: 'invalid_code',
  invalid_credentials: 'invalid_code',
  over_sms_send_rate_limit: 'too_soon',
  over_request_rate_limit: 'too_soon',
  validation_failed: 'invalid_phone',
};

function toAuthError(error: SupabaseAuthError | null): AuthError {
  return new AuthError(ERROR_CODES[error?.code ?? ''] ?? 'unknown');
}

function toSession(session: SupabaseSession | null): Session | null {
  if (!session) return null;
  const phone = session.user.phone ?? '';
  return { userId: session.user.id, phone: phone.startsWith('+') ? phone : `+${phone}` };
}

// canal sms: el hook send_sms de Auth lo entrega por WhatsApp (ATDE-14)
export function createSupabaseAuthGateway(getAuth: () => SupabaseAuth = () => getSupabase().auth): AuthGateway {
  return {
    async requestCode(phone) {
      const { error } = await getAuth().signInWithOtp({ phone });
      if (error) throw toAuthError(error);
    },
    async verifyCode(phone, token) {
      const { data, error } = await getAuth().verifyOtp({ phone, token, type: 'sms' });
      const session = toSession(data.session);
      if (error || !session) throw toAuthError(error);
      return session;
    },
    async getSession() {
      const { data } = await getAuth().getSession();
      return toSession(data.session);
    },
    onSessionChange(listener) {
      const { data } = getAuth().onAuthStateChange((_event, session) => listener(toSession(session)));
      return () => data.subscription.unsubscribe();
    },
  };
}
