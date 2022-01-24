import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_selected_feed_market_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/save_default_feed_market_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/util/discovery_engine_markets.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

/// A temporary wrapper for the [DiscoveryEngine].
/// Once the engine is ready, we can remove this class.
///
/// What we are awaiting:
/// - [changeDocumentFeedback] to return an EngineEvent with information about the [Document].
/// - an implementation for [search].
@LazySingleton(as: DiscoveryEngine)
class AppDiscoveryEngine implements DiscoveryEngine {
  final DiscoveryEngine _engine;

  /// temp solution:
  /// Once search is supported, we drop this.
  final StreamController<EngineEvent> _tempSearchEvents =
      StreamController<EngineEvent>.broadcast();

  /// temp solution:
  /// - [changeDocumentFeedback] is a fire-and-forget right now
  /// - instead, we need an [EngineEvent] which also contains info about the changed [Document].
  ///
  /// for now, the expando allows us to store the missing params as a weak-key map.
  final Expando<DocumentFeedbackChange> _eventMap =
      Expando<DocumentFeedbackChange>();

  @visibleForTesting
  AppDiscoveryEngine(this._engine);

  @factoryMethod
  static Future<AppDiscoveryEngine> create(
    GetSelectedFeedMarketsUseCase getSelectedFeedMarketsUseCase,
    SaveDefaultFeedMarketUseCase saveDefaultFeedMarketUseCase,
  ) async {
    await _saveDefaultFeedMarket(saveDefaultFeedMarketUseCase);

    final localMarkets = await getSelectedFeedMarketsUseCase.singleOutput(none);

    final markets = localMarkets
        .map((e) =>
            FeedMarket(countryCode: e.countryCode, langCode: e.languageCode))
        .toSet();

    final configuration = Configuration(
      apiKey: Env.searchApiSecretKey,
      apiBaseUrl: Env.searchApiBaseUrl,
      applicationDirectoryPath: '/',
      maxItemsPerFeedBatch: 20,
      feedMarkets: markets,
    );
    final engine = await DiscoveryEngine.init(configuration: configuration);

    return AppDiscoveryEngine(engine);
  }

  static Future<void> _saveDefaultFeedMarket(
    SaveDefaultFeedMarketUseCase useCase,
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
      _engine.changeConfiguration(
        feedMarkets: feedMarkets,
        maxItemsPerFeedBatch: maxItemsPerFeedBatch,
      );

  @override
  Future<EngineEvent> changeDocumentFeedback({
    required DocumentId documentId,
    required DocumentFeedback feedback,
  }) async {
    final engineEvent = await _engine.changeDocumentFeedback(
        documentId: documentId, feedback: feedback);

    _eventMap[engineEvent] = DocumentFeedbackChange(
      documentId: documentId,
      feedback: feedback,
    );

    return engineEvent;
  }

  @override
  Future<EngineEvent> closeFeedDocuments(Set<DocumentId> documentIds) =>
      _engine.closeFeedDocuments(documentIds);

  /// As we also need search events, which are not yet supported, we override
  /// this getter so that it includes our temp search event Stream.
  @override
  Stream<EngineEvent> get engineEvents => Rx.merge([
        _engine.engineEvents,
        _tempSearchEvents.stream,
      ]);

  @override
  Future<EngineEvent> logDocumentTime({
    required DocumentId documentId,
    required DocumentViewMode mode,
    required int seconds,
  }) =>
      _engine.logDocumentTime(
        documentId: documentId,
        mode: mode,
        seconds: seconds,
      );

  @override
  Future<EngineEvent> requestFeed() => _engine.requestFeed();

  @override
  Future<EngineEvent> requestNextFeedBatch() => _engine.requestNextFeedBatch();

  @override
  Future<EngineEvent> resetEngine() => _engine.resetEngine();

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
  Future<void> dispose() => _engine.dispose();

  @override
  Future<EngineEvent> send(ClientEvent event) => _engine.send(event);
}
