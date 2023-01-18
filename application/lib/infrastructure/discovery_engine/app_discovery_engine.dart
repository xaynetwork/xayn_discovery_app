import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document_id.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document_view_mode.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/client_event.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/engine_event.dart';
import 'package:xayn_discovery_app/domain/model/legacy/user_reaction.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/infrastructure/util/async_init.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

/// needs to be public, used elsewhere
const int _kSearchPageSize = 20;
const int _kFeedBatchSize = 2;

const String _kHeadlinesProviderPath = '/newscatcher/v1/latest-headlines';
const String _kNewsProviderPath = '/newscatcher/v1/search-news';

/// A wrapper for the [DiscoveryEngine].
@LazySingleton(as: DiscoveryEngine)
class AppDiscoveryEngine with AsyncInitMixin implements DiscoveryEngine {
  late final GetLocalMarketsUseCase _getLocalMarketsUseCase;
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
    required GetLocalMarketsUseCase getLocalMarketsUseCase,
    bool initialized = true,
    String? applicationDocumentsPathDirectory,
  })  : _saveInitialFeedMarketUseCase = saveInitialFeedMarketUseCase,
        _getLocalMarketsUseCase = getLocalMarketsUseCase {
    if (!initialized) {
      startInitializing();
    }
  }

  @factoryMethod
  factory AppDiscoveryEngine.init({
    required GetLocalMarketsUseCase getLocalMarketsUseCase,
  }) =>
      AppDiscoveryEngine(
        getLocalMarketsUseCase: getLocalMarketsUseCase,
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
      headlinesProviderPath: _kHeadlinesProviderPath,
      newsProviderPath: _kNewsProviderPath,
    );

    _updateFeedMarketIdentityParam(feedMarkets);

    _inputLog.add(
      '[init]\n<configuration> ${configuration.toString()}',
    );
    _engine = await DiscoveryEngine.init(configuration: configuration)
        .catchError((e) {
      logger.e('DiscoveryEngine.init: $e');
    });
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
  Future<EngineEvent> closeActiveSearch() {
    _inputLog.add('[closeSearch]');
    return safeRun(() => _engine.closeActiveSearch());
  }

  @override
  Future<EngineEvent> requestNextActiveSearchBatch() {
    _inputLog.add('[requestNextSearchBatch]');
    return safeRun(() => _engine.requestNextActiveSearchBatch());
  }

  @override
  Future<EngineEvent> requestQuerySearch(String queryTerm) {
    _inputLog.add('[requestSearch]\n<queryTerm> $queryTerm');
    return safeRun(() => _engine.requestQuerySearch(queryTerm));
  }

  @override
  Future<EngineEvent> restoreActiveSearch() {
    _inputLog.add('[restoreSearch]');
    return safeRun(() => _engine.restoreActiveSearch());
  }

  @override
  Future<EngineEvent> getActiveSearchTerm() {
    _inputLog.add('[getSearchTerm]');
    return safeRun(() => _engine.getActiveSearchTerm());
  }

  @override
  Future<EngineEvent> requestDeepSearch(DocumentId id) {
    _inputLog.add('[requestDeepSearch]');
    return safeRun(() => _engine.requestDeepSearch(id));
  }

  void _updateFeedMarketIdentityParam(FeedMarkets markets) {
    final param = NumberOfActiveSelectedCountriesIdentityParam(markets.length);
    _setIdentityParamUseCase.call(param);
  }

  @override
  String? get lastDbOverrideError => _engine.lastDbOverrideError;
}
