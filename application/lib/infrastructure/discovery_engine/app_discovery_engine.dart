import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_selected_feed_market_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/save_initial_feed_market_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/util/async_init.dart';
import 'package:xayn_discovery_app/infrastructure/util/discovery_engine_markets.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

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
  late DiscoveryEngine _engine;

  /// temp solution:
  /// Once search is supported, we drop this.
  late final StreamController<EngineEvent> _tempSearchEvents =
      StreamController<EngineEvent>.broadcast();

  /// temp solution:
  /// - [changeDocumentFeedback] is a fire-and-forget right now
  /// - instead, we need an [EngineEvent] which also contains info about the changed [Document].
  ///
  /// for now, the expando allows us to store the missing params as a weak-key map.
  final Expando<DocumentFeedbackChange> _eventMap =
      Expando<DocumentFeedbackChange>();

  @visibleForTesting
  AppDiscoveryEngine.test(DiscoveryEngine engine) : _engine = engine;

  @visibleForTesting
  AppDiscoveryEngine(
      {required GetSelectedFeedMarketsUseCase getSelectedFeedMarketsUseCase,
      required SaveInitialFeedMarketUseCase saveInitialFeedMarketUseCase,
      bool initialized = true})
      : _getSelectedFeedMarketsUseCase = getSelectedFeedMarketsUseCase,
        _saveInitialFeedMarketUseCase = saveInitialFeedMarketUseCase {
    if (!initialized) {
      startInitializing();
    }
  }

  @factoryMethod
  factory AppDiscoveryEngine.init({
    required GetSelectedFeedMarketsUseCase getSelectedFeedMarketsUseCase,
    required SaveInitialFeedMarketUseCase saveInitialFeedMarketUseCase,
  }) =>
      AppDiscoveryEngine(
        getSelectedFeedMarketsUseCase: getSelectedFeedMarketsUseCase,
        saveInitialFeedMarketUseCase: saveInitialFeedMarketUseCase,
        initialized: false,
      );

  @override
  Future<void> init() async {
    await _saveInitialFeedMarket(_saveInitialFeedMarketUseCase);

    final localMarkets =
        await _getSelectedFeedMarketsUseCase.singleOutput(none);

    final markets = localMarkets
        .map((e) =>
            FeedMarket(countryCode: e.countryCode, langCode: e.languageCode))
        .toSet();

    final configuration = Configuration(
      apiKey: Env.searchApiSecretKey,
      apiBaseUrl: Env.searchApiBaseUrl,
      applicationDirectoryPath: '/engine/',
      maxItemsPerFeedBatch: 20,
      feedMarkets: markets,
      assetsUrl: '',
      manifest: Manifest(const []),
    );

    _engine = await DiscoveryEngine.init(configuration: configuration);
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
  }) =>
      safeRun(() => _engine.changeConfiguration(
            feedMarkets: feedMarkets,
            maxItemsPerFeedBatch: maxItemsPerFeedBatch,
          ));

  @override
  Future<EngineEvent> changeUserReaction({
    required DocumentId documentId,
    required UserReaction userReaction,
  }) async {
    final engineEvent = await safeRun(
      () => _engine.changeUserReaction(
        documentId: documentId,
        userReaction: userReaction,
      ),
    );

    _eventMap[engineEvent] = DocumentFeedbackChange(
      documentId: documentId,
      userReaction: userReaction,
    );

    return engineEvent;
  }

  @override
  Future<EngineEvent> closeFeedDocuments(Set<DocumentId> documentIds) =>
      safeRun(() => _engine.closeFeedDocuments(documentIds));

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
  }) =>
      safeRun(() => _engine.logDocumentTime(
            documentId: documentId,
            mode: mode,
            seconds: seconds,
          ));

  @override
  Future<EngineEvent> requestFeed() => safeRun(() => _engine.requestFeed());

  @override
  Future<EngineEvent> requestNextFeedBatch() =>
      safeRun(() => _engine.requestNextFeedBatch());

  Future<EngineEvent> search(String searchTerm) {
    throw UnimplementedError();
  }

  /// temporary workaround for adding events that are not yet handled
  /// by the discovery engine.
  void tempAddEvent(EngineEvent event) => _tempSearchEvents.add(event);

  /// temporary workaround for getting info on what [Document] was changed
  /// when [changeDocumentFeedback] was called.
  DocumentFeedbackChange? resolveChangeDocumentFeedbackParameters(
          EngineEvent engineEvent) =>
      _eventMap[engineEvent];

  @override
  Future<void> dispose() => safeRun(() => _engine.dispose());

  @override
  Future<EngineEvent> send(ClientEvent event) =>
      safeRun(() => _engine.send(event));
}
