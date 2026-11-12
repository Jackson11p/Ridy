export const CODE_LENGTH = 6;
const CODE = new RegExp(`^\\d{${CODE_LENGTH}}$`);
const MS_PER_SECOND = 1000;

export const RESEND_SECONDS = 60;

export function isValidCode(code: string): boolean {
  return CODE.test(code);
}

export function secondsUntilResend(sentAt: number, now: number): number {
  const elapsed = (now - sentAt) / MS_PER_SECOND;
  return Math.max(0, Math.ceil(RESEND_SECONDS - elapsed));
}

const COSTA_RICA_PARTS = /^(\+506)(\d{4})(\d{4})$/;
const SECONDS_PER_MINUTE = 60;

export function formatPhone(phone: string): string {
  return phone.replace(COSTA_RICA_PARTS, '$1 $2 $3');
}

export function formatCountdown(seconds: number): string {
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${pad(Math.floor(seconds / SECONDS_PER_MINUTE))}:${pad(seconds % SECONDS_PER_MINUTE)}`;
}
