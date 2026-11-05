export const supportedLanguages = ['es', 'en'] as const;
export type Language = (typeof supportedLanguages)[number];

const isSupported = (code: string): code is Language =>
  (supportedLanguages as readonly string[]).includes(code);

export function resolveLanguage(deviceLanguages: readonly string[]): Language {
  return deviceLanguages.find(isSupported) ?? 'es';
}
