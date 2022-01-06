import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@LazySingleton(as: DiscoveryEngine)
class AppDiscoveryEngine implements DiscoveryEngine {
  final DiscoveryEngine _engine;
  final StreamController<EngineEvent> _tempEvents =
      StreamController<EngineEvent>.broadcast();
  final Expando<DocumentFeedbackChange> _eventMap =
      Expando<DocumentFeedbackChange>();

  @visibleForTesting
  AppDiscoveryEngine(this._engine);

  @factoryMethod
  static Future<AppDiscoveryEngine> create() async {
    // todo: read from AppSettings
    const configuration = Configuration(
      apiKey: Env.searchApiSecretKey,
      apiBaseUrl: Env.searchApiBaseUrl,
      applicationDirectoryPath: '/',
      maxItemsPerFeedBatch: 20,
      feedMarket: 'en-US',
    );
    final engine = await DiscoveryEngine.init(configuration: configuration);

    return AppDiscoveryEngine(engine);
  }

  @override
  Future<EngineEvent> changeConfiguration({
    String? feedMarket,
    int? maxItemsPerFeedBatch,
  }) =>
      _engine.changeConfiguration(
          feedMarket: feedMarket, maxItemsPerFeedBatch: maxItemsPerFeedBatch);

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

  @override
  Stream<EngineEvent> get engineEvents => Rx.merge([
        _engine.engineEvents,
        _tempEvents.stream,
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
  void tempAddEvent(EngineEvent event) => _tempEvents.add(event);

  DocumentFeedbackChange? resolveChangeDocumentFeedbackParameters(
          EngineEvent engineEvent) =>
      _eventMap[engineEvent];
}
