import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/get_local_markets_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/db_entity_to_feed_market_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_type_markets_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_feed_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_feed_type_markets_repository.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/marketing_analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/notifications/local_notifications_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/notifications/remote_notification.dart';
import 'package:xayn_discovery_app/infrastructure/service/notifications/remote_notifications_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/set_identity_param_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_selected_feed_market_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/save_initial_feed_market_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_type_markets/save_feed_type_markets_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

String? applicationDocumentsPathDirectory;

@injectable
class EngineBackgroundNewsService {
  final RemoteNotificationsService _remoteNotificationsService;
  final LocalNotificationsService _localNotificationsService;

  EngineBackgroundNewsService(
    this._remoteNotificationsService,
    this._localNotificationsService,
  ) {
    _init();
  }

  void _init() {
    _remoteNotificationsService.notificationStream
        .asBroadcastStream()
        .listen(_onNotificationReceived);
  }

  void _onNotificationReceived(RemoteNotification remoteNotification) async {
    if (applicationDocumentsPathDirectory == null) {
      logger.i('[Engine Background News] Path not set.');
      return;
    }

    final event = await _fetchNews(applicationDocumentsPathDirectory!);
    if (event is! NextFeedBatchRequestSucceeded) {
      logger.i('[Engine Background News] Engine event: $event');
      return;
    }

    if (event.items.isEmpty) {
      logger.i('[Engine Background News] No documents');
      return;
    }

    final document = event.items.first;
    logger
        .i('[Engine Background News] Latest news: ${document.resource.title}');

    await _localNotificationsService.sendNotification(
      title: document.resource.title,
      body: document.resource.snippet,
      documentId: UniqueId.fromTrustedString(document.documentId.toString()),
      delay: const Duration(seconds: 1),
    );
  }

  Future<EngineEvent> _fetchNews(String arg) async {
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
    // ignore: invalid_use_of_visible_for_testing_member
    final engine = AppDiscoveryEngine(
      getSelectedFeedMarketsUseCase: getSelectedFeedMarketsUseCase,
      saveInitialFeedMarketUseCase: saveInitialFeedMarketUseCase,
      sendAnalyticsUseCase: sendAnalyticsUseCase,
      getLocalMarketsUseCase: getLocalMarketsUseCase,
      setIdentityParamUseCase: setIdentityParamUseCase,
      initialized: false,
      applicationDocumentsPathDirectory: arg,
    );
    return engine.requestNextFeedBatch();
  }
}
