export type Palette = {
  background: string;
  surface: string;
  text: string;
  muted: string;
  border: string;
  action: string;
  onAction: string;
  accent: string;
  danger: string;
  dangerAction: string;
  disabled: string;
  info: string;
  success: string;
  warning: string;
  dangerBg: string;
};

export const lightPalette: Palette = {
  background: '#F5F7FB',
  surface: '#FFFFFF',
  text: '#10233F',
  muted: '#59687D',
  border: '#DCE3EC',
  action: '#0962D9',
  onAction: '#FFFFFF',
  accent: '#1677FF',
  danger: '#B52337',
  dangerAction: '#E63946',
  disabled: '#DCE3EC',
  info: '#EAF2FF',
  success: '#E6F5EE',
  warning: '#FFF3D4',
  dangerBg: '#FDECEF',
};

export const darkPalette: Palette = {
  background: '#0B1424',
  surface: '#142238',
  text: '#F4F7FC',
  muted: '#B1BFD1',
  border: '#34465F',
  action: '#0962D9',
  onAction: '#FFFFFF',
  accent: '#72AEFF',
  danger: '#FF8FA1',
  dangerAction: '#B52337',
  disabled: '#263750',
  info: '#183453',
  success: '#12392F',
  warning: '#3C301B',
  dangerBg: '#402231',
};
