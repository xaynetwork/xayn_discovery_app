import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/hosted_discovery_engine_service.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@lazySingleton
class HostedDiscoveryEngine implements DiscoveryEngine {
  final HostedDiscoveryEngineService _service;

  const HostedDiscoveryEngine(this._service);

  @override
  Future<EngineEvent> addSourceToExcludedList(Source source) {
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> addSourceToTrustedList(Source source) {
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> changeConfiguration(
      {FeedMarkets? feedMarkets,
      int? maxItemsPerFeedBatch,
      int? maxItemsPerSearchBatch}) {
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> changeUserReaction({
    required DocumentId documentId,
    required UserReaction userReaction,
  }) =>
      _service.changeUserReaction(
          documentId: documentId, userReaction: userReaction);

  @override
  Future<EngineEvent> closeActiveSearch() {
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> closeFeedDocuments(Set<DocumentId> documentIds) =>
      _service.closeFeedDocuments(documentIds);

  @override
  Future<void> dispose() {
    throw UnimplementedError();
  }

  @override
  Stream<EngineEvent> get engineEvents => _service.events;

  @override
  Future<EngineEvent> getActiveSearchTerm() {
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> getAvailableSourcesList(String fuzzySearchTerm) {
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> getExcludedSourcesList() {
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> getTrustedSourcesList() {
    throw UnimplementedError();
  }

  @override
  String? get lastDbOverrideError => throw UnimplementedError();

  @override
  Future<EngineEvent> logDocumentTime(
      {required DocumentId documentId,
      required DocumentViewMode mode,
      required int seconds}) {
    return Future.value(const EngineEvent.clientEventSucceeded());
  }

  @override
  Future<EngineEvent> overrideSources(
      {required Set<Source> trustedSources,
      required Set<Source> excludedSources}) {
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> removeSourceFromExcludedList(Source source) {
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> removeSourceFromTrustedList(Source source) {
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> requestDeepSearch(DocumentId id) {
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> requestNextActiveSearchBatch() {
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> requestNextFeedBatch() =>
      _service.requestNextFeedBatch(RequestFeedType.nextBatch);

  @override
  Future<EngineEvent> requestQuerySearch(String queryTerm) {
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> requestTopicSearch(String topic) {
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> requestTrendingTopics() {
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> resetAi() {
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> restoreActiveSearch() {
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> restoreFeed() =>
      _service.requestNextFeedBatch(RequestFeedType.restore);

  @override
  Future<EngineEvent> send(ClientEvent event) {
    throw UnimplementedError();
  }
}
