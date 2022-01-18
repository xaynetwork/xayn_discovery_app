import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

abstract class AnalyticsService {
  Future<void> send(AnalyticsEvent event);

  Future<void> flush();
}

@LazySingleton(as: AnalyticsService)
class AmplitudeAnalyticsService implements AnalyticsService {
  final Amplitude _amplitude;

  @visibleForTesting
  AmplitudeAnalyticsService({required Amplitude amplitude})
      : _amplitude = amplitude;

  @factoryMethod
  static Future<AnalyticsService> initialized() async {
    final amplitude = Amplitude.getInstance();

    await amplitude.init(Env.amplitudeApiKey);
    await amplitude.trackingSessionEvents(true);
    await amplitude.setUseDynamicConfig(true);

    return AmplitudeAnalyticsService(amplitude: amplitude);
  }

  @override
  Future<void> flush() => _amplitude.uploadEvents();

  @override
  Future<void> send(AnalyticsEvent event) async {
    await _amplitude.logEvent(
      event.type,
      eventProperties: event.properties
          // this ensures that unserializable objects like i.e. [UniqueId] can tracked in analytics
          .map((key, value) => MapEntry(key, value.toString())),
    );

    logger.i('Analytics event has been fired:\n${{
      'type': event.type,
      'properties': event.properties,
    }}');
  }
}
