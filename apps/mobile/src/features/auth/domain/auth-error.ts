export type AuthErrorCode = 'invalid_phone' | 'invalid_code' | 'too_soon' | 'unknown';

export class AuthError extends Error {
  constructor(readonly code: AuthErrorCode) {
    super(code);
    this.name = 'AuthError';
  }
}

export function errorCodeOf(error: unknown): AuthErrorCode {
  return error instanceof AuthError ? error.code : 'unknown';
}
