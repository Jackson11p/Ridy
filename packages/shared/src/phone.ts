import { z } from 'zod';

const SEPARATORS = /[\s()-]/g;
const E164 = /^\+?[1-9]\d{7,14}$/;

export const phoneSchema = z
  .string()
  .transform((raw) => raw.replace(SEPARATORS, ''))
  .pipe(z.string().regex(E164, 'Teléfono inválido: usa formato internacional, p. ej. +506 8888 7777'))
  .transform((digits) => `+${digits.replace(/^\+/, '')}`);

export type Phone = z.infer<typeof phoneSchema>;
