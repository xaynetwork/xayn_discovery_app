import 'package:injectable/injectable.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';

import 'analytics_events.dart';

@singleton
class AnalyticsService {
  AnalyticsService();

  Amplitude get _analytics => Amplitude.getInstance();

  init() {
    _analytics
      ..init(Env.amplitudeApiKey)
      ..trackingSessionEvents(true)
      ..setUseDynamicConfig(true)
      // Enable COPPA privacy guard. This is useful when you choose not to report sensitive user information.
      ..enableCoppaControl();

    //Toggle Event for testing purposes only
    //TODO: remove later
    logEvent(AnalyticsEvents.clickedCardEvent);
  }

  logEvent(AnalyticsEvent event) => _analytics.logEvent(
        event.name,
        eventProperties: event.properties,
      );
}
