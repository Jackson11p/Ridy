import { z } from 'zod';

const EXPO_PUSH_TOKEN = /^Expo(nent)?PushToken\[[^\]]+\]$/;
const MAX_LENGTH = 255;

export const expoPushTokenSchema = z
  .string()
  .max(MAX_LENGTH, 'Token push demasiado largo')
  .regex(EXPO_PUSH_TOKEN, 'Token push inválido: se espera ExpoPushToken[...]');

export type ExpoPushToken = z.infer<typeof expoPushTokenSchema>;
