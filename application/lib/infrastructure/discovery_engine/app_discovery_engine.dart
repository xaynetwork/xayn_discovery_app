import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/extensions/feed_market_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type_markets.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/engine_init_failed_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_selected_feed_market_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/save_initial_feed_market_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_type_markets/get_feed_type_markets_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_type_markets/save_feed_type_markets_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/util/async_init.dart';
import 'package:xayn_discovery_app/infrastructure/util/discovery_engine_markets.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

/// A wrapper for the [DiscoveryEngine].
@LazySingleton(as: DiscoveryEngine)
class AppDiscoveryEngine with AsyncInitMixin implements DiscoveryEngine {
  late final GetSelectedFeedMarketsUseCase _getSelectedFeedMarketsUseCase;
  late final SaveInitialFeedMarketUseCase _saveInitialFeedMarketUseCase;
  late final SendAnalyticsUseCase _sendAnalyticsUseCase;
  late final GetFeedTypeMarketsUseCase _getFeedTypeMarketsUseCase;
  late final SaveFeedTypeMarketsUseCase _saveFeedTypeMarketsUseCase;
  late DiscoveryEngine _engine;

  final StreamController<String> _inputLog =
      StreamController<String>.broadcast();

  /// A log stream of input events to the engine
  Stream<String> get engineInputEventsLog => _inputLog.stream;

  @visibleForTesting
  AppDiscoveryEngine.test(DiscoveryEngine engine) : _engine = engine;

  @visibleForTesting
  AppDiscoveryEngine({
    required GetSelectedFeedMarketsUseCase getSelectedFeedMarketsUseCase,
    required SaveInitialFeedMarketUseCase saveInitialFeedMarketUseCase,
    required SendAnalyticsUseCase sendAnalyticsUseCase,
    required GetFeedTypeMarketsUseCase getFeedTypeMarketsUseCase,
    required SaveFeedTypeMarketsUseCase saveFeedTypeMarketsUseCase,
    bool initialized = true,
  })  : _getSelectedFeedMarketsUseCase = getSelectedFeedMarketsUseCase,
        _saveInitialFeedMarketUseCase = saveInitialFeedMarketUseCase,
        _sendAnalyticsUseCase = sendAnalyticsUseCase,
        _getFeedTypeMarketsUseCase = getFeedTypeMarketsUseCase,
        _saveFeedTypeMarketsUseCase = saveFeedTypeMarketsUseCase {
    if (!initialized) {
      startInitializing();
    }
  }

  @factoryMethod
  factory AppDiscoveryEngine.init({
    required GetSelectedFeedMarketsUseCase getSelectedFeedMarketsUseCase,
    required SaveInitialFeedMarketUseCase saveInitialFeedMarketUseCase,
    required SendAnalyticsUseCase sendAnalyticsUseCase,
    required GetFeedTypeMarketsUseCase getFeedTypeMarketsUseCase,
    required SaveFeedTypeMarketsUseCase saveFeedTypeMarketsUseCase,
  }) =>
      AppDiscoveryEngine(
        getSelectedFeedMarketsUseCase: getSelectedFeedMarketsUseCase,
        saveInitialFeedMarketUseCase: saveInitialFeedMarketUseCase,
        sendAnalyticsUseCase: sendAnalyticsUseCase,
        getFeedTypeMarketsUseCase: getFeedTypeMarketsUseCase,
        saveFeedTypeMarketsUseCase: saveFeedTypeMarketsUseCase,
        initialized: false,
      );

  @override
  Future<void> init() async {
    // TODO use this as dependency
    final applicationDocumentsDirectory =
        await getApplicationDocumentsDirectory();
    final manifest = await FlutterManifestReader().read();
    final copier = FlutterBundleAssetCopier(
      appDir: applicationDocumentsDirectory.path,
      bundleAssetsPath: 'assets/ai',
    );
    await copier.copyAssets(manifest);

    await _saveInitialFeedMarket(_saveInitialFeedMarketUseCase);

    final configuration = Configuration(
      apiKey: Env.searchApiSecretKey,
      apiBaseUrl: Env.searchApiBaseUrl,
      assetsUrl: Env.aiAssetsUrl,
      applicationDirectoryPath: applicationDocumentsDirectory.path,
      maxItemsPerFeedBatch: 2,
      maxItemsPerSearchBatch: 2,
      feedMarkets: await _getLocalMarkets(),
      manifest: manifest,
    );

    _inputLog.add(
      '[init]\n<configuration> ${configuration.toString()}',
    );
    _engine = await DiscoveryEngine.init(configuration: configuration)
        .catchError((e) {
      _sendAnalyticsUseCase(
        EngineInitFailedEvent(error: e),
      );

      logger.e('DiscoveryEngine.init: $e');
    });
  }

  Future<bool> areMarketsOutdated(FeedType feedType) async {
    final markets = await _getLocalMarkets();
    final localMarkets = markets.map((it) => it.toLocal()).toSet();
    final feedTypeMarkets =
        await _getFeedTypeMarketsUseCase.singleOutput(feedType);

    return feedTypeMarkets.feedMarkets.length != localMarkets.length ||
        !feedTypeMarkets.feedMarkets.every(localMarkets.contains);
  }

  Future<EngineEvent> updateMarkets(FeedType feedType) async {
    final nextMarkets = await _getLocalMarkets();
    late final UniqueId id;

    switch (feedType) {
      case FeedType.feed:
        id = FeedTypeMarkets.feedId;
        break;
      case FeedType.search:
        id = FeedTypeMarkets.searchId;
        break;
    }

    await _saveFeedTypeMarketsUseCase.singleOutput(
      FeedTypeMarkets(
        id: id,
        feedType: feedType,
        feedMarkets: nextMarkets.map((it) => it.toLocal()).toSet(),
      ),
    );

    return await changeConfiguration(feedMarkets: nextMarkets);
  }

  Future<void> _saveInitialFeedMarket(
    SaveInitialFeedMarketUseCase useCase,
  ) async {
    final deviceLocale = WidgetsBinding.instance!.window.locale;
    final input = SaveDefaultFeedMarketInput(
      deviceLocale,
      defaultFeedMarket,
      supportedFeedMarkets,
    );
    await useCase.call(input);
  }

  @override
  Future<EngineEvent> changeConfiguration({
    FeedMarkets? feedMarkets,
    int? maxItemsPerFeedBatch,
    int? maxItemsPerSearchBatch,
  }) {
    _inputLog.add(
      '[changeConfiguration]\n<feedMarkets> $feedMarkets\n<nmaxItemsPerFeedBatch> $maxItemsPerFeedBatch'
      '\n<nmaxItemsPerSearchBatch> $maxItemsPerFeedBatch',
    );
    return safeRun(() => _engine.changeConfiguration(
          feedMarkets: feedMarkets,
          maxItemsPerFeedBatch: maxItemsPerFeedBatch,
        ));
  }

  @override
  Future<EngineEvent> changeUserReaction({
    required DocumentId documentId,
    required UserReaction userReaction,
  }) async {
    _inputLog.add(
      '[changeUserReaction]\n<documentId> \n$documentId \n<userReaction> \n$userReaction',
    );
    final engineEvent = await safeRun(
      () => _engine.changeUserReaction(
        documentId: documentId,
        userReaction: userReaction,
      ),
    );

    return engineEvent;
  }

  @override
  Future<EngineEvent> closeFeedDocuments(Set<DocumentId> documentIds) {
    _inputLog.add(
      '[closeFeedDocuments]\n<documentIds> \n${documentIds.join('\n')}',
    );
    return safeRun(() => _engine.closeFeedDocuments(documentIds));
  }

  @override
  Stream<EngineEvent> get engineEvents =>
      Stream.fromFuture(safeRun(() => _engine.engineEvents))
          .asyncExpand((events) => events);

  @override
  Future<EngineEvent> logDocumentTime({
    required DocumentId documentId,
    required DocumentViewMode mode,
    required int seconds,
  }) {
    _inputLog.add(
      '[logDocumentTime]\n<documentId> $documentId\n<mode> $mode\n<seconds> $seconds',
    );
    return safeRun(
      () => _engine.logDocumentTime(
          documentId: documentId, mode: mode, seconds: seconds),
    );
  }

  @override
  Future<EngineEvent> restoreFeed() {
    _inputLog.add('[restoreFeed]');
    return safeRun(() => _engine.restoreFeed());
  }

  @override
  Future<EngineEvent> requestNextFeedBatch() {
    _inputLog.add('[requestNextFeedBatch]');
    return safeRun(() => _engine.requestNextFeedBatch());
  }

  @override
  Future<void> dispose() {
    _inputLog
      ..add('[dispose]')
      ..close();
    return safeRun(() => _engine.dispose());
  }

  @override
  Future<EngineEvent> send(ClientEvent event) {
    _inputLog.add('[send]\n<ClientEvent> $ClientEvent');
    return safeRun(() => _engine.send(event));
  }

  Future<Set<FeedMarket>> _getLocalMarkets() async {
    final localMarkets =
        await _getSelectedFeedMarketsUseCase.singleOutput(none);

    return localMarkets
        .sortedBy((it) => '${it.countryCode}|${it.languageCode}')
        .map((e) =>
            FeedMarket(countryCode: e.countryCode, langCode: e.languageCode))
        .toSet();
  }

  @override
  Future<EngineEvent> closeSearch() {
    _inputLog.add('[closeSearch]');
    return safeRun(() => _engine.closeSearch());
  }

  @override
  Future<EngineEvent> requestNextSearchBatch() {
    _inputLog.add('[requestNextSearchBatch]');
    return safeRun(() => _engine.requestNextSearchBatch());
  }

  @override
  Future<EngineEvent> requestSearch(String queryTerm) {
    _inputLog.add('[requestSearch]\n<queryTerm> $queryTerm');
    return safeRun(() => _engine.requestSearch(queryTerm));
  }

  @override
  Future<EngineEvent> restoreSearch() {
    _inputLog.add('[restoreSearch]');
    return safeRun(() => _engine.restoreSearch());
  }

  @override
  Future<EngineEvent> addSourceToExcludedList(Uri source) {
    _inputLog.add('[addSourceToExcludedList]');
    return safeRun(() => _engine.addSourceToExcludedList(source));
  }

  @override
  Future<EngineEvent> getExcludedSourcesList() {
    _inputLog.add('[getExcludedSourcesList]');
    return safeRun(() => _engine.getExcludedSourcesList());
  }

  @override
  Future<EngineEvent> getSearchTerm() {
    _inputLog.add('[getSearchTerm]');
    return safeRun(() => _engine.getSearchTerm());
  }

  @override
  Future<EngineEvent> removeSourceFromExcludedList(Uri source) {
    _inputLog.add('[removeSourceFromExcludedList]');
    return safeRun(() => _engine.removeSourceFromExcludedList(source));
  }
}
