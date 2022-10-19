import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:system_info2/system_info2.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/base/identity_param.dart';
import 'package:xayn_discovery_app/infrastructure/util/async_init.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

const String _kCoresEntry = 'cores';
const String _kCoresSocketEntry = 'socket';
const String _kCoresVendorEntry = 'vendor';
const String _kCoresArchEntry = 'arch';

abstract class AnalyticsService {
  Future<void> send(AnalyticsEvent event);

  Future<void> updateIdentityParam(IdentityParam param);

  Future<void> updateIdentityParams(Set<IdentityParam> params);

  Future<void> flush();
}

@LazySingleton(as: AnalyticsService)
@releaseEnvironment
class MixpanelAnalyticsService with AsyncInitMixin implements AnalyticsService {
  late final Mixpanel _mixpanel;
  final String _userId;

  MixpanelAnalyticsService({
    required String userId,
    bool initialized = true,
  }) : _userId = userId {
    if (!initialized) {
      startInitializing();
    }
  }

  @visibleForTesting
  MixpanelAnalyticsService.test({
    required Mixpanel mixpanel,
    required String userId,
  })  : _mixpanel = mixpanel,
        _userId = userId;

  @override
  Future<void> init() async {
    _mixpanel = await Mixpanel.init(Env.mixpanelToken);
    _mixpanel.setServerURL(Env.mixpanelServerUrl);
    _mixpanel.identify(_userId);
    _mixpanel.setUseIpAddressForGeolocation(false);
    _mixpanel.setLoggingEnabled(EnvironmentHelper.kIsInternalFlavor);
    if (Platform.isAndroid) _preambleDeviceCores();
  }

  @factoryMethod
  factory MixpanelAnalyticsService.init(
    AppStatusRepository appStatusRepository,
  ) =>
      MixpanelAnalyticsService(
        userId: appStatusRepository.appStatus.userId.value,
        initialized: false,
      );

  @override
  Future<void> flush() => safeRun(() => _mixpanel.flush());

  @override
  Future<void> send(AnalyticsEvent event) async {
    await safeRun(() {
      _mixpanel.track(
        event.type,
        properties: event.properties,
      );

      logger.i('Analytics event has been fired:\n${{
        'type': event.type,
        'properties': event.properties,
      }}');
    });
  }

  /// uses setOnce to log info on the device's cores
  void _preambleDeviceCores() {
    final deviceCoresProperties = SysInfo.cores
        .map(
          (it) => {
            _kCoresSocketEntry: it.socket,
            _kCoresVendorEntry: it.vendor,
            _kCoresArchEntry: it.architecture.name,
          },
        )
        .toList(growable: false);

    _mixpanel.getPeople().setOnce(_kCoresEntry, deviceCoresProperties);
  }

  @override
  Future<void> updateIdentityParam(IdentityParam param) async {
    await safeRun(() {
      _mixpanel.getPeople().set(param.key, param.value);
      logger.i('Analytics identity param was changed: $param');
    });
  }

  @override
  Future<void> updateIdentityParams(Set<IdentityParam> params) async {
    await safeRun(() {
      for (final param in params) {
        _mixpanel.getPeople().set(param.key, param.value);
      }
      logger.i('Analytics identity params were changed: $params');
    });
  }
}

/// Analytics service is disabled in debug and test modes
@LazySingleton(as: AnalyticsService)
@debugEnvironment
@testEnvironment
class AnalyticsServiceDebugMode implements AnalyticsService {
  @override
  Future<void> send(AnalyticsEvent event) async {
    logger.i('DEBUG: Analytics event has been fired:\n${{
      'type': event.type,
      'properties': event.properties,
    }}');
  }

  @override
  Future<void> flush() async {
    logger.i('DEBUG: Analytics flushed');
  }

  @override
  Future<void> updateIdentityParam(IdentityParam param) async {
    logger.i('DEBUG: Analytics identity param was changed: $param');
  }

  @override
  Future<void> updateIdentityParams(Set<IdentityParam> params) async {
    logger.i('DEBUG: Analytics identity params were changed: $params');
  }
}
