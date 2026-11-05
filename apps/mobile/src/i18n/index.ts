import { getLocales } from 'expo-localization';
import { createInstance } from 'i18next';
import { initReactI18next } from 'react-i18next';

import en from './locales/en.json';
import es from './locales/es.json';
import { resolveLanguage } from './resolve-language';

const deviceLanguages = getLocales().flatMap((locale) => locale.languageCode ?? []);

export const i18n = createInstance();

i18n.use(initReactI18next).init({
  resources: { es: { translation: es }, en: { translation: en } },
  lng: resolveLanguage(deviceLanguages),
  fallbackLng: 'es',
  interpolation: { escapeValue: false },
});
