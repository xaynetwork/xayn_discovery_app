import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@LazySingleton(as: DiscoveryEngine)
class AppDiscoveryEngine implements DiscoveryEngine {
  final DiscoveryEngine _engine;

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
  }) =>
      _engine.changeDocumentFeedback(
          documentId: documentId, feedback: feedback);

  @override
  Future<EngineEvent> closeFeedDocuments(Set<DocumentId> documentIds) =>
      _engine.closeFeedDocuments(documentIds);

  @override
  Stream<EngineEvent> get engineEvents => _engine.engineEvents;

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
}
