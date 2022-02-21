import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/identify.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:system_info2/system_info2.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/infrastructure/util/async_init.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';
import 'package:xayn_discovery_app/presentation/utils/map_utils.dart';

const String _kCoresEntry = 'cores';
const String _kCoresSocketEntry = 'socket';
const String _kCoresVendorEntry = 'vendor';
const String _kCoresArchEntry = 'arch';

abstract class AnalyticsService {
  Future<void> send(AnalyticsEvent event);

  Future<void> flush();
}

@LazySingleton(as: AnalyticsService)
class AmplitudeAnalyticsService
    with AsyncInitMixin
    implements AnalyticsService {
  final Amplitude _amplitude;

  @visibleForTesting
  AmplitudeAnalyticsService({
    required Amplitude amplitude,
    bool initialized = true,
  }) : _amplitude = amplitude {
    if (!initialized) {
      startInitializing();
    }
  }

  @override
  Future<void> init() async {
    await _amplitude.init(Env.amplitudeApiKey);
    await _amplitude.trackingSessionEvents(true);
    await _amplitude.setUseDynamicConfig(true);
    await _preamble();
  }

  @factoryMethod
  factory AmplitudeAnalyticsService.init() => AmplitudeAnalyticsService(
      amplitude: Amplitude.getInstance(), initialized: false);

  @override
  Future<void> flush() => safeRun(() => _amplitude.uploadEvents());

  @override
  Future<void> send(AnalyticsEvent event) async {
    safeRun(() async {
      await _amplitude.logEvent(
        event.type,
        eventProperties: event.properties.toSerializableMap(),
      );

      logger.i('Analytics event has been fired:\n${{
        'type': event.type,
        'properties': event.properties,
      }}');
    });
  }

  /// uses setOnce to log info on the device's cores
  Future<void> _preamble() async {
    final identify = Identify();

    identify.setOnce(
      _kCoresEntry,
      SysInfo.cores
          .map(
            (it) => {
              _kCoresSocketEntry: it.socket,
              _kCoresVendorEntry: it.vendor,
              _kCoresArchEntry: it.architecture.name,
            },
          )
          .toList(growable: false),
    );

    await _amplitude.identify(identify);
  }
}
