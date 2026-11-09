import { AppText } from './app-text';

type ScreenTitleProps = { text: string };

export function ScreenTitle({ text }: ScreenTitleProps) {
  return (
    <AppText variant="display" accessibilityRole="header">
      {text}
    </AppText>
  );
}
