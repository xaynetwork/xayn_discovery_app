import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

/// An [AnalyticsEvent] which tracks when alternative redeem code window is open.
class OpenRedeemCodeWindowEvent extends AnalyticsEvent {
  OpenRedeemCodeWindowEvent()
      : super(
          'openRedeemCodeWindow',
        );
}
