import 'package:background_fetch/background_fetch.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/get_local_markets_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/db_entity_to_feed_market_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_type_markets_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_feed_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_feed_type_markets_repository.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/marketing_analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/set_identity_param_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_selected_feed_market_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/save_initial_feed_market_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_type_markets/save_feed_type_markets_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

enum BackgroundEngineFetchStatus {
  available,
  denied,
  restricted,
  unknown,
}

abstract class BackgroundEngineFetchService {
  Future<BackgroundEngineFetchStatus> getStatus();
  Future<BackgroundEngineFetchStatus> start();
  Future<BackgroundEngineFetchStatus> stop();
  Future<BackgroundEngineFetchStatus> configureAndStart();
}

class BackgroundEngineFetchServiceImpl implements BackgroundEngineFetchService {
  final _BackgroundEngineFetchStatusMapper _mapper =
      _BackgroundEngineFetchStatusMapper();
  final Function(EngineEvent) _engineEventCallback;

  BackgroundEngineFetchServiceImpl(this._engineEventCallback);

  BackgroundEngineFetchStatus _mapStatus(int value) => _mapper.map(value);

  @override
  Future<BackgroundEngineFetchStatus> getStatus() =>
      BackgroundFetch.status.then(_mapStatus);

  @override
  Future<BackgroundEngineFetchStatus> start() =>
      BackgroundFetch.start().then(_mapStatus);

  @override
  Future<BackgroundEngineFetchStatus> stop() =>
      BackgroundFetch.stop().then(_mapStatus);

  void _onFetch(String taskId) async {
    logger.i("[BackgroundFetch] Event received $taskId");

    final event = await _fetchNews();
    _engineEventCallback(event);

    BackgroundFetch.finish(taskId);
  }

  void _onTimeout(String taskId) {
    logger.i("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
    BackgroundFetch.finish(taskId);
  }

  @override
  Future<BackgroundEngineFetchStatus> configureAndStart() =>
      BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          requiredNetworkType: NetworkType.NONE,
        ),
        _onFetch,
        _onTimeout,
      ).then(_mapStatus);

  Future<EngineEvent> _fetchNews() {
    final dbEntityMapToFeedMarketMapper = DbEntityMapToFeedMarketMapper();
    final feedMarketToDbEntityMapMapper = FeedMarketToDbEntityMapMapper();
    final feedSettingsRepository =
        HiveFeedSettingsRepository(FeedSettingsMapper(
      dbEntityMapToFeedMarketMapper,
      feedMarketToDbEntityMapMapper,
    ));
    final getSelectedFeedMarketsUseCase =
        GetSelectedFeedMarketsUseCase(feedSettingsRepository);
    final feedTypeMarketsRepository =
        HiveFeedTypeMarketsRepository(FeedTypeMarketsMapper(
      dbEntityMapToFeedMarketMapper,
      feedMarketToDbEntityMapMapper,
    ));
    final saveFeedTypeMarketsUseCase =
        SaveFeedTypeMarketsUseCase(feedTypeMarketsRepository);
    final saveInitialFeedMarketUseCase = SaveInitialFeedMarketUseCase(
      feedSettingsRepository,
      saveFeedTypeMarketsUseCase,
    );
    final analyticsService = AnalyticsServiceDebugMode();
    final sendAnalyticsUseCase = SendAnalyticsUseCase(
      analyticsService,
      MarketingAnalyticsServiceDebugMode(),
    );
    final getLocalMarketsUseCase =
        GetLocalMarketsUseCase(getSelectedFeedMarketsUseCase);
    final setIdentityParamUseCase = SetIdentityParamUseCase(analyticsService);
    final engine = AppDiscoveryEngine.init(
      getSelectedFeedMarketsUseCase: getSelectedFeedMarketsUseCase,
      saveInitialFeedMarketUseCase: saveInitialFeedMarketUseCase,
      sendAnalyticsUseCase: sendAnalyticsUseCase,
      getLocalMarketsUseCase: getLocalMarketsUseCase,
      setIdentityParamUseCase: setIdentityParamUseCase,
    );
    return engine.requestNextFeedBatch();
  }
}

class _BackgroundEngineFetchStatusMapper
    implements Mapper<int, BackgroundEngineFetchStatus> {
  @override
  BackgroundEngineFetchStatus map(int input) {
    switch (input) {
      case BackgroundFetch.STATUS_RESTRICTED:
        return BackgroundEngineFetchStatus.restricted;
      case BackgroundFetch.STATUS_DENIED:
        return BackgroundEngineFetchStatus.denied;
      case BackgroundFetch.STATUS_AVAILABLE:
        return BackgroundEngineFetchStatus.available;
      default:
        return BackgroundEngineFetchStatus.unknown;
    }
  }
}
