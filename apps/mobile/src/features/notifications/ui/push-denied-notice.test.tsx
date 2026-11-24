import { render, screen } from '@testing-library/react-native';

import { i18n } from '@/i18n';

import { PushDeniedNotice } from './push-denied-notice';

describe('PushDeniedNotice', () => {
  it('tells the user they will not get alerts when permission was denied', async () => {
    await render(<PushDeniedNotice status="denied" />);

    expect(screen.getByText(i18n.t('notifications.denied'))).toBeTruthy();
  });

  it.each(['registered', 'unavailable', null] as const)('stays hidden when the status is %p', async (status) => {
    await render(<PushDeniedNotice status={status} />);

    expect(screen.queryByText(i18n.t('notifications.denied'))).toBeNull();
  });

  it('has the text in Spanish and English', () => {
    expect(i18n.getFixedT('es')('notifications.denied')).not.toBe('notifications.denied');
    expect(i18n.getFixedT('en')('notifications.denied')).not.toBe('notifications.denied');
  });
});
