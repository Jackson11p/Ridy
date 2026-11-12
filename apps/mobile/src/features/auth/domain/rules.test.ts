import { AuthError, errorCodeOf } from './auth-error';
import { isValidCode, RESEND_SECONDS, secondsUntilResend } from './rules';

describe('isValidCode', () => {
  it.each(['123456', '000000'])('accepts %s', (code) => {
    expect(isValidCode(code)).toBe(true);
  });

  it.each(['', '12345', '1234567', '12a456', ' 123456', '12 456'])('rejects "%s"', (code) => {
    expect(isValidCode(code)).toBe(false);
  });
});

describe('secondsUntilResend', () => {
  const sentAt = 1_000_000;

  it('waits the full window right after sending', () => {
    expect(RESEND_SECONDS).toBe(60);
    expect(secondsUntilResend(sentAt, sentAt)).toBe(60);
  });

  it('rounds partial seconds up', () => {
    expect(secondsUntilResend(sentAt, sentAt + 30_500)).toBe(30);
    expect(secondsUntilResend(sentAt, sentAt + 59_001)).toBe(1);
  });

  it('never goes below zero', () => {
    expect(secondsUntilResend(sentAt, sentAt + 60_000)).toBe(0);
    expect(secondsUntilResend(sentAt, sentAt + 999_000)).toBe(0);
  });
});

describe('AuthError', () => {
  it('carries a domain code', () => {
    const error = new AuthError('invalid_code');

    expect(error).toBeInstanceOf(Error);
    expect(error.code).toBe('invalid_code');
    expect(errorCodeOf(error)).toBe('invalid_code');
    expect(errorCodeOf(new Error('network'))).toBe('unknown');
  });
});
