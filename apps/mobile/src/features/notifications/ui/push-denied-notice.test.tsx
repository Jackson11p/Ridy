import { render, screen } from '@testing-library/react-native';

import { i18n } from '@/i18n';

import { PushDeniedNotice } from './push-denied-notice';

describe('PushDeniedNotice', () => {
  it('tells the user they will not get alerts when permission was denied', async () => {
    await render(<PushDeniedNotice status="denied" />);

    expect(screen.getByText(i18n.t('notifications.denied'))).toBeTruthy();
  });

  it('tells the user they will not get alerts when the device has no push', async () => {
    await render(<PushDeniedNotice status="unavailable" />);

    expect(screen.getByText(i18n.t('notifications.unavailable'))).toBeTruthy();
  });

  it.each(['registered', null] as const)('stays hidden when the status is %p', async (status) => {
    await render(<PushDeniedNotice status={status} />);

    expect(screen.queryByText(i18n.t('notifications.denied'))).toBeNull();
    expect(screen.queryByText(i18n.t('notifications.unavailable'))).toBeNull();
  });

  it.each(['notifications.denied', 'notifications.unavailable'])('has %p in Spanish and English', (key) => {
    expect(i18n.getFixedT('es')(key)).not.toBe(key);
    expect(i18n.getFixedT('en')(key)).not.toBe(key);
  });
});
