import 'package:injectable/injectable.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

@lazySingleton
class AnalyticsService {
  AnalyticsService() {
    _init();
  }

  Amplitude get _analytics => Amplitude.getInstance();

  _init() {
    _analytics
      ..init(Env.amplitudeApiKey)
      ..trackingSessionEvents(true)
      ..setUseDynamicConfig(true);
  }

  void logEvent(AnalyticsEvent event) {
    _analytics.logEvent(
      event.name,
      eventProperties: event.properties,
    );

    logger.i('Analytics event has been fired: ' + event.name);
  }
}
