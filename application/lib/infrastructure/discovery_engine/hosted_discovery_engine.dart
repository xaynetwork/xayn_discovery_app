import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/hosted_discovery_engine_service.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@LazySingleton(as: DiscoveryEngine)
class HostedDiscoveryEngine implements DiscoveryEngine {
  final HostedDiscoveryEngineService _service;

  const HostedDiscoveryEngine(this._service);

  @override
  Future<EngineEvent> addSourceToExcludedList(Source source) {
    // TODO: implement addSourceToExcludedList
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> addSourceToTrustedList(Source source) {
    // TODO: implement addSourceToTrustedList
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> changeConfiguration(
      {FeedMarkets? feedMarkets,
      int? maxItemsPerFeedBatch,
      int? maxItemsPerSearchBatch}) {
    // TODO: implement changeConfiguration
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
    // TODO: implement closeActiveSearch
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> closeFeedDocuments(Set<DocumentId> documentIds) {
    // TODO: implement closeFeedDocuments
    throw UnimplementedError();
  }

  @override
  Future<void> dispose() {
    // TODO: implement dispose
    throw UnimplementedError();
  }

  @override
  Stream<EngineEvent> get engineEvents => _service.events;

  @override
  Future<EngineEvent> getActiveSearchTerm() {
    // TODO: implement getActiveSearchTerm
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> getAvailableSourcesList(String fuzzySearchTerm) {
    // TODO: implement getAvailableSourcesList
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> getExcludedSourcesList() {
    // TODO: implement getExcludedSourcesList
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> getTrustedSourcesList() {
    // TODO: implement getTrustedSourcesList
    throw UnimplementedError();
  }

  @override
  // TODO: implement lastDbOverrideError
  String? get lastDbOverrideError => throw UnimplementedError();

  @override
  Future<EngineEvent> logDocumentTime(
      {required DocumentId documentId,
      required DocumentViewMode mode,
      required int seconds}) {
    // TODO: implement logDocumentTime
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> overrideSources(
      {required Set<Source> trustedSources,
      required Set<Source> excludedSources}) {
    // TODO: implement overrideSources
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> removeSourceFromExcludedList(Source source) {
    // TODO: implement removeSourceFromExcludedList
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> removeSourceFromTrustedList(Source source) {
    // TODO: implement removeSourceFromTrustedList
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> requestDeepSearch(DocumentId id) {
    // TODO: implement requestDeepSearch
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> requestNextActiveSearchBatch() {
    // TODO: implement requestNextActiveSearchBatch
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> requestNextFeedBatch() =>
      _service.requestNextFeedBatch(RequestFeedType.nextBatch);

  @override
  Future<EngineEvent> requestQuerySearch(String queryTerm) {
    // TODO: implement requestQuerySearch
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> requestTopicSearch(String topic) {
    // TODO: implement requestTopicSearch
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> requestTrendingTopics() {
    // TODO: implement requestTrendingTopics
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> resetAi() {
    // TODO: implement resetAi
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> restoreActiveSearch() {
    // TODO: implement restoreActiveSearch
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> restoreFeed() =>
      _service.requestNextFeedBatch(RequestFeedType.restore);

  @override
  Future<EngineEvent> send(ClientEvent event) {
    // TODO: implement send
    throw UnimplementedError();
  }
}
