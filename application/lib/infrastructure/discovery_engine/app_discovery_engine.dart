import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/engine_init_failed_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_selected_feed_market_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/save_initial_feed_market_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/util/async_init.dart';
import 'package:xayn_discovery_app/infrastructure/util/discovery_engine_markets.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

/// A temporary wrapper for the [DiscoveryEngine].
/// Once the engine is ready, we can remove this class.
///
/// What we are awaiting:
/// - [changeDocumentFeedback] to return an EngineEvent with information about the [Document].
/// - an implementation for [search].
@LazySingleton(as: DiscoveryEngine)
class AppDiscoveryEngine with AsyncInitMixin implements DiscoveryEngine {
  late final GetSelectedFeedMarketsUseCase _getSelectedFeedMarketsUseCase;
  late final SaveInitialFeedMarketUseCase _saveInitialFeedMarketUseCase;
  late final SendAnalyticsUseCase _sendAnalyticsUseCase;
  late DiscoveryEngine _engine;
  late Set<FeedMarket> _localMarkets;

  /// temp solution:
  /// Once search is supported, we drop this.
  late final StreamController<EngineEvent> _tempSearchEvents =
      StreamController<EngineEvent>.broadcast();

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
    bool initialized = true,
  })  : _getSelectedFeedMarketsUseCase = getSelectedFeedMarketsUseCase,
        _saveInitialFeedMarketUseCase = saveInitialFeedMarketUseCase,
        _sendAnalyticsUseCase = sendAnalyticsUseCase {
    if (!initialized) {
      startInitializing();
    }
  }

  @factoryMethod
  factory AppDiscoveryEngine.init({
    required GetSelectedFeedMarketsUseCase getSelectedFeedMarketsUseCase,
    required SaveInitialFeedMarketUseCase saveInitialFeedMarketUseCase,
    required SendAnalyticsUseCase sendAnalyticsUseCase,
  }) =>
      AppDiscoveryEngine(
        getSelectedFeedMarketsUseCase: getSelectedFeedMarketsUseCase,
        saveInitialFeedMarketUseCase: saveInitialFeedMarketUseCase,
        sendAnalyticsUseCase: sendAnalyticsUseCase,
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

    _localMarkets = await _getLocalMarkets();

    final configuration = Configuration(
      apiKey: Env.searchApiSecretKey,
      apiBaseUrl: Env.searchApiBaseUrl,
      assetsUrl: Env.aiAssetsUrl,
      applicationDirectoryPath: applicationDocumentsDirectory.path,
      maxItemsPerFeedBatch: 2,
      maxItemsPerSearchBatch: 2,
      feedMarkets: _localMarkets,
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

  Future<bool> areMarketsOutdated() async {
    const equality = SetEquality();
    final markets = await _getLocalMarkets();

    return !equality.equals(_localMarkets, markets);
  }

  Future<EngineEvent> updateMarkets() async {
    _localMarkets = await _getLocalMarkets();

    return await changeConfiguration(feedMarkets: _localMarkets);
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

  /// As we also need search events, which are not yet supported, we override
  /// this getter so that it includes our temp search event Stream.
  @override
  Stream<EngineEvent> get engineEvents {
    final engineEvents = Stream.fromFuture(safeRun(() => _engine.engineEvents))
        .asyncExpand((events) => events);

    return Rx.merge([engineEvents, _tempSearchEvents.stream]);
  }

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

  /// temporary workaround for adding events that are not yet handled
  /// by the discovery engine.
  void tempAddEvent(EngineEvent event) => _tempSearchEvents.add(event);

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
}
