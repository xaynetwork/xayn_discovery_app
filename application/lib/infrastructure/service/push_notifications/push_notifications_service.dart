import 'package:airship_flutter/airship_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/get_local_markets_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/db_entity_to_feed_market_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_type_markets_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_feed_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_feed_type_markets_repository.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/marketing_analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/set_identity_param_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_selected_feed_market_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/save_initial_feed_market_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_type_markets/save_feed_type_markets_use_case.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kChannelKey = 'basic_channel';

String? applicationDocumentsPathDirectory;

Future<EngineEvent> _fetchNews(String arg) async {
  final dbEntityMapToFeedMarketMapper = DbEntityMapToFeedMarketMapper();
  final feedMarketToDbEntityMapMapper = FeedMarketToDbEntityMapMapper();
  final feedSettingsRepository = HiveFeedSettingsRepository(FeedSettingsMapper(
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

@injectable
class PushNotificationsService {
  PushNotificationsService() {
    _setupRemote();
    _setupLocal();
  }

  void _pushMessageHandler(PushReceivedEvent event) async {
    // ignore: avoid_print
    print('Notification received');

    final event = await _fetchNews(applicationDocumentsPathDirectory!);
    // final event = await compute(_fetchNews, applicationDocumentsPathDirectory!);
    if (event is! NextFeedBatchRequestSucceeded) {
      // ignore: avoid_print
      print('Engine event: $event');
      return;
    }
    if (event.items.isEmpty) {
      // ignore: avoid_print
      print('No documents');
      return;
    }
    final document = event.items.first;

    // ignore: avoid_print
    print('Latest news: ${document.resource.title}');
    await PushNotificationsService.sendLocal(
      title: document.resource.title,
      body: document.resource.snippet,
    );
  }

  void _setupRemote() async {
    // Enable notifications (prompts on iOS)
    Airship.setUserNotificationsEnabled(true);

    Airship.onChannelRegistration.listen((event) =>
        // ignore: avoid_print
        print('Channel Registration, channelId: ${event.channelId}'));

    // Channel ID
    final channelId = await Airship.channelId;
    // ignore: avoid_print
    print('channelId: $channelId');

    Airship.onPushReceived.listen(_pushMessageHandler);
  }

  void _setupLocal() async {
    AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelKey: _kChannelKey,
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
          )
        ],
        // Channel groups are only visual and are not required
        channelGroups: [
          NotificationChannelGroup(
              channelGroupkey: 'basic_channel_group',
              channelGroupName: 'Basic group')
        ],
        debug: true);

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    AwesomeNotifications()
        .actionStream
        .listen((ReceivedNotification receivedNotification) {});
  }

  static Future<bool> sendLocal({
    required String title,
    required String body,
  }) {
    return AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: _kChannelKey,
        title: title,
        body: body,
      ),
    );
  }
}
