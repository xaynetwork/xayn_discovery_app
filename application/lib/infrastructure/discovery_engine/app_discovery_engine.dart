import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/get_local_markets_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/engine_init_failed_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/number_of_active_selected_countries_identity_param.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/set_identity_param_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_selected_feed_market_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/save_initial_feed_market_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/util/async_init.dart';
import 'package:xayn_discovery_app/infrastructure/util/discovery_engine_markets.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

/// needs to be public, used elsewhere
const int _kSearchPageSize = 20;
const int _kFeedBatchSize = 3;

/// A wrapper for the [DiscoveryEngine].
@LazySingleton(as: DiscoveryEngine)
class AppDiscoveryEngine with AsyncInitMixin implements DiscoveryEngine {
  late final SaveInitialFeedMarketUseCase _saveInitialFeedMarketUseCase;
  late final SendAnalyticsUseCase _sendAnalyticsUseCase;
  late final GetLocalMarketsUseCase _getLocalMarketsUseCase;
  late final SetIdentityParamUseCase _setIdentityParamUseCase;
  late DiscoveryEngine _engine;

  static int get searchPageSize => _kSearchPageSize;

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
    required GetLocalMarketsUseCase getLocalMarketsUseCase,
    required SetIdentityParamUseCase setIdentityParamUseCase,
    bool initialized = true,
  })  : _saveInitialFeedMarketUseCase = saveInitialFeedMarketUseCase,
        _sendAnalyticsUseCase = sendAnalyticsUseCase,
        _getLocalMarketsUseCase = getLocalMarketsUseCase,
        _setIdentityParamUseCase = setIdentityParamUseCase {
    if (!initialized) {
      startInitializing();
    }
  }

  @factoryMethod
  factory AppDiscoveryEngine.init({
    required GetSelectedFeedMarketsUseCase getSelectedFeedMarketsUseCase,
    required SaveInitialFeedMarketUseCase saveInitialFeedMarketUseCase,
    required SendAnalyticsUseCase sendAnalyticsUseCase,
    required GetLocalMarketsUseCase getLocalMarketsUseCase,
    required SetIdentityParamUseCase setIdentityParamUseCase,
  }) =>
      AppDiscoveryEngine(
        getSelectedFeedMarketsUseCase: getSelectedFeedMarketsUseCase,
        saveInitialFeedMarketUseCase: saveInitialFeedMarketUseCase,
        sendAnalyticsUseCase: sendAnalyticsUseCase,
        getLocalMarketsUseCase: getLocalMarketsUseCase,
        setIdentityParamUseCase: setIdentityParamUseCase,
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

    final feedMarkets = await _getLocalMarketsUseCase.singleOutput(none);
    final configuration = Configuration(
      apiKey: Env.searchApiSecretKey,
      apiBaseUrl: Env.searchApiBaseUrl,
      assetsUrl: Env.aiAssetsUrl,
      applicationDirectoryPath: applicationDocumentsDirectory.path,
      maxItemsPerFeedBatch: _kFeedBatchSize,
      maxItemsPerSearchBatch: _kSearchPageSize,
      feedMarkets: feedMarkets,
      manifest: manifest,
    );

    _updateFeedMarketIdentityParam(feedMarkets);

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
    if (feedMarkets != null) {
      _updateFeedMarketIdentityParam(feedMarkets);
    }
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
  Future<EngineEvent> addSourceToExcludedList(Source source) {
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
  Future<EngineEvent> removeSourceFromExcludedList(Source source) {
    _inputLog.add('[removeSourceFromExcludedList]');
    return safeRun(() => _engine.removeSourceFromExcludedList(source));
  }

  void _updateFeedMarketIdentityParam(FeedMarkets markets) {
    final param = NumberOfActiveSelectedCountriesIdentityParam(markets.length);
    _setIdentityParamUseCase.call(param);
  }
}
