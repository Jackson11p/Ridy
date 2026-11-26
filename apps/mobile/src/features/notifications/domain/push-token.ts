import type { ExpoPushToken } from '@ridy/shared';

export type PushStatus = 'registered' | 'denied' | 'unavailable';

export type PushPermission = 'granted' | 'denied' | 'unavailable';

export type TokenListener = (token: string) => void;

// I/O del teléfono (permiso y token Expo); infrastructure lo implementa sin lanzar: lo imposible es 'unavailable' o null
export interface PushTokenProvider {
  requestPermission(): Promise<PushPermission>;
  getToken(): Promise<string | null>;
  onTokenChange(listener: TokenListener): () => void;
}

// I/O del perfil: guarda o borra el token de quien inició sesión
export interface PushTokenStore {
  save(token: ExpoPushToken): Promise<void>;
  clear(): Promise<void>;
}

export type PushRegistry = { provider: PushTokenProvider; store: PushTokenStore };
