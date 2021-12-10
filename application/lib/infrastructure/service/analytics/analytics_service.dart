import 'package:injectable/injectable.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';

import 'analytics_events.dart';

// Configuration for users in Europe
// https://developers.amplitude.com/docs/flutter-setup#eu-data-residency
const kEuServerZone = 'EU';

@singleton
class AnalyticsService {
  AnalyticsService() {
    _init();
  }

  Amplitude get _analytics => Amplitude.getInstance();

  _init() {
    _analytics
      ..init(Env.amplitudeApiKey)
      ..trackingSessionEvents(true)
      ..setUseDynamicConfig(true)

      // TODO: We should first detect if the user is in Europe
      ..setServerZone(kEuServerZone)

      // Enable COPPA privacy guard. This is useful when you choose not to report sensitive user information.
      ..enableCoppaControl();

    logEvent(AnalyticsEvents.sessionStartEvent);
  }

  logEvent(AnalyticsEvent event) => _analytics.logEvent(
        event.name,
        eventProperties: event.properties,
      );
}
