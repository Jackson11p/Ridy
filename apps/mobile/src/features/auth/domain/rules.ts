const CODE = /^\d{6}$/;
const MS_PER_SECOND = 1000;

export const RESEND_SECONDS = 60;

export function isValidCode(code: string): boolean {
  return CODE.test(code);
}

export function secondsUntilResend(sentAt: number, now: number): number {
  const elapsed = (now - sentAt) / MS_PER_SECOND;
  return Math.max(0, Math.ceil(RESEND_SECONDS - elapsed));
}
