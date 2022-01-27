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
  Future<void>? _ongoingInit;

  @visibleForTesting
  AmplitudeAnalyticsService(
      {required Amplitude amplitude, bool initialized = true})
      : _amplitude = amplitude {
    if (!initialized) {
      _ongoingInit = _init();
    }
  }

  Future<void> _init() async {
    await _amplitude.init(Env.amplitudeApiKey);
    await _amplitude.trackingSessionEvents(true);
    await _amplitude.setUseDynamicConfig(true);
    _ongoingInit = null;
  }

  Future<void> _checkInit(Future<void> Function() run) async {
    final ongoingInit = _ongoingInit;
    if (ongoingInit != null) {
      await ongoingInit;
    }

    return run();
  }

  @factoryMethod
  factory AmplitudeAnalyticsService.init() => AmplitudeAnalyticsService(
      amplitude: Amplitude.getInstance(), initialized: false);

  @override
  Future<void> flush() => _checkInit(() => _amplitude.uploadEvents());

  @override
  Future<void> send(AnalyticsEvent event) async {
    _checkInit(() async {
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
    });
  }
}
