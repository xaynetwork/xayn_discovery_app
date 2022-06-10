// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/api/events/engine_events.dart';
// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/domain/models/source.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

class TempEngineEvent implements EngineEvent {
  @override
  TResult map<TResult extends Object?>(
      {required TResult Function(RestoreFeedSucceeded value)
          restoreFeedSucceeded,
      required TResult Function(RestoreFeedFailed value) restoreFeedFailed,
      required TResult Function(NextFeedBatchRequestSucceeded value)
          nextFeedBatchRequestSucceeded,
      required TResult Function(NextFeedBatchRequestFailed value)
          nextFeedBatchRequestFailed,
      required TResult Function(NextFeedBatchAvailable value)
          nextFeedBatchAvailable,
      required TResult Function(ExcludedSourcesListRequestSucceeded value)
          excludedSourcesListRequestSucceeded,
      required TResult Function(ExcludedSourcesListRequestFailed value)
          excludedSourcesListRequestFailed,
      required TResult Function(TrustedSourcesListRequestSucceeded value)
          trustedSourcesListRequestSucceeded,
      required TResult Function(TrustedSourcesListRequestFailed value)
          trustedSourcesListRequestFailed,
      required TResult Function(AvailableSourcesListRequestSucceeded value)
          availableSourcesListRequestSucceeded,
      required TResult Function(AvailableSourcesListRequestFailed value)
          availableSourcesListRequestFailed,
      required TResult Function(FetchingAssetsStarted value)
          fetchingAssetsStarted,
      required TResult Function(FetchingAssetsProgressed value)
          fetchingAssetsProgressed,
      required TResult Function(FetchingAssetsFinished value)
          fetchingAssetsFinished,
      required TResult Function(ClientEventSucceeded value)
          clientEventSucceeded,
      required TResult Function(ResetAiSucceeded value) resetAiSucceeded,
      required TResult Function(EngineExceptionRaised value)
          engineExceptionRaised,
      required TResult Function(DocumentsUpdated value) documentsUpdated,
      required TResult Function(ActiveSearchRequestSucceeded value)
          activeSearchRequestSucceeded,
      required TResult Function(ActiveSearchRequestFailed value)
          activeSearchRequestFailed,
      required TResult Function(NextActiveSearchBatchRequestSucceeded value)
          nextActiveSearchBatchRequestSucceeded,
      required TResult Function(NextActiveSearchBatchRequestFailed value)
          nextActiveSearchBatchRequestFailed,
      required TResult Function(RestoreActiveSearchSucceeded value)
          restoreActiveSearchSucceeded,
      required TResult Function(RestoreActiveSearchFailed value)
          restoreActiveSearchFailed,
      required TResult Function(ActiveSearchTermRequestSucceeded value)
          activeSearchTermRequestSucceeded,
      required TResult Function(ActiveSearchTermRequestFailed value)
          activeSearchTermRequestFailed,
      required TResult Function(DeepSearchRequestSucceeded value)
          deepSearchRequestSucceeded,
      required TResult Function(DeepSearchRequestFailed value)
          deepSearchRequestFailed,
      required TResult Function(TrendingTopicsRequestSucceeded value)
          trendingTopicsRequestSucceeded,
      required TResult Function(TrendingTopicsRequestFailed value)
          trendingTopicsRequestFailed}) {
    // TODO: implement map
    throw UnimplementedError();
  }

  @override
  TResult? mapOrNull<TResult extends Object?>(
      {TResult Function(RestoreFeedSucceeded value)? restoreFeedSucceeded,
      TResult Function(RestoreFeedFailed value)? restoreFeedFailed,
      TResult Function(NextFeedBatchRequestSucceeded value)?
          nextFeedBatchRequestSucceeded,
      TResult Function(NextFeedBatchRequestFailed value)?
          nextFeedBatchRequestFailed,
      TResult Function(NextFeedBatchAvailable value)? nextFeedBatchAvailable,
      TResult Function(ExcludedSourcesListRequestSucceeded value)?
          excludedSourcesListRequestSucceeded,
      TResult Function(ExcludedSourcesListRequestFailed value)?
          excludedSourcesListRequestFailed,
      TResult Function(TrustedSourcesListRequestSucceeded value)?
          trustedSourcesListRequestSucceeded,
      TResult Function(TrustedSourcesListRequestFailed value)?
          trustedSourcesListRequestFailed,
      TResult Function(AvailableSourcesListRequestSucceeded value)?
          availableSourcesListRequestSucceeded,
      TResult Function(AvailableSourcesListRequestFailed value)?
          availableSourcesListRequestFailed,
      TResult Function(FetchingAssetsStarted value)? fetchingAssetsStarted,
      TResult Function(FetchingAssetsProgressed value)?
          fetchingAssetsProgressed,
      TResult Function(FetchingAssetsFinished value)? fetchingAssetsFinished,
      TResult Function(ClientEventSucceeded value)? clientEventSucceeded,
      TResult Function(ResetAiSucceeded value)? resetAiSucceeded,
      TResult Function(EngineExceptionRaised value)? engineExceptionRaised,
      TResult Function(DocumentsUpdated value)? documentsUpdated,
      TResult Function(ActiveSearchRequestSucceeded value)?
          activeSearchRequestSucceeded,
      TResult Function(ActiveSearchRequestFailed value)?
          activeSearchRequestFailed,
      TResult Function(NextActiveSearchBatchRequestSucceeded value)?
          nextActiveSearchBatchRequestSucceeded,
      TResult Function(NextActiveSearchBatchRequestFailed value)?
          nextActiveSearchBatchRequestFailed,
      TResult Function(RestoreActiveSearchSucceeded value)?
          restoreActiveSearchSucceeded,
      TResult Function(RestoreActiveSearchFailed value)?
          restoreActiveSearchFailed,
      TResult Function(ActiveSearchTermRequestSucceeded value)?
          activeSearchTermRequestSucceeded,
      TResult Function(ActiveSearchTermRequestFailed value)?
          activeSearchTermRequestFailed,
      TResult Function(DeepSearchRequestSucceeded value)?
          deepSearchRequestSucceeded,
      TResult Function(DeepSearchRequestFailed value)? deepSearchRequestFailed,
      TResult Function(TrendingTopicsRequestSucceeded value)?
          trendingTopicsRequestSucceeded,
      TResult Function(TrendingTopicsRequestFailed value)?
          trendingTopicsRequestFailed}) {
    // TODO: implement mapOrNull
    throw UnimplementedError();
  }

  @override
  TResult maybeMap<TResult extends Object?>(
      {TResult Function(RestoreFeedSucceeded value)? restoreFeedSucceeded,
      TResult Function(RestoreFeedFailed value)? restoreFeedFailed,
      TResult Function(NextFeedBatchRequestSucceeded value)?
          nextFeedBatchRequestSucceeded,
      TResult Function(NextFeedBatchRequestFailed value)?
          nextFeedBatchRequestFailed,
      TResult Function(NextFeedBatchAvailable value)? nextFeedBatchAvailable,
      TResult Function(ExcludedSourcesListRequestSucceeded value)?
          excludedSourcesListRequestSucceeded,
      TResult Function(ExcludedSourcesListRequestFailed value)?
          excludedSourcesListRequestFailed,
      TResult Function(TrustedSourcesListRequestSucceeded value)?
          trustedSourcesListRequestSucceeded,
      TResult Function(TrustedSourcesListRequestFailed value)?
          trustedSourcesListRequestFailed,
      TResult Function(AvailableSourcesListRequestSucceeded value)?
          availableSourcesListRequestSucceeded,
      TResult Function(AvailableSourcesListRequestFailed value)?
          availableSourcesListRequestFailed,
      TResult Function(FetchingAssetsStarted value)? fetchingAssetsStarted,
      TResult Function(FetchingAssetsProgressed value)?
          fetchingAssetsProgressed,
      TResult Function(FetchingAssetsFinished value)? fetchingAssetsFinished,
      TResult Function(ClientEventSucceeded value)? clientEventSucceeded,
      TResult Function(ResetAiSucceeded value)? resetAiSucceeded,
      TResult Function(EngineExceptionRaised value)? engineExceptionRaised,
      TResult Function(DocumentsUpdated value)? documentsUpdated,
      TResult Function(ActiveSearchRequestSucceeded value)?
          activeSearchRequestSucceeded,
      TResult Function(ActiveSearchRequestFailed value)?
          activeSearchRequestFailed,
      TResult Function(NextActiveSearchBatchRequestSucceeded value)?
          nextActiveSearchBatchRequestSucceeded,
      TResult Function(NextActiveSearchBatchRequestFailed value)?
          nextActiveSearchBatchRequestFailed,
      TResult Function(RestoreActiveSearchSucceeded value)?
          restoreActiveSearchSucceeded,
      TResult Function(RestoreActiveSearchFailed value)?
          restoreActiveSearchFailed,
      TResult Function(ActiveSearchTermRequestSucceeded value)?
          activeSearchTermRequestSucceeded,
      TResult Function(ActiveSearchTermRequestFailed value)?
          activeSearchTermRequestFailed,
      TResult Function(DeepSearchRequestSucceeded value)?
          deepSearchRequestSucceeded,
      TResult Function(DeepSearchRequestFailed value)? deepSearchRequestFailed,
      TResult Function(TrendingTopicsRequestSucceeded value)?
          trendingTopicsRequestSucceeded,
      TResult Function(TrendingTopicsRequestFailed value)?
          trendingTopicsRequestFailed,
      required TResult Function() orElse}) {
    // TODO: implement maybeMap
    throw UnimplementedError();
  }

  @override
  TResult maybeWhen<TResult extends Object?>(
      {TResult Function(List<Document> items)? restoreFeedSucceeded,
      TResult Function(FeedFailureReason reason)? restoreFeedFailed,
      TResult Function(List<Document> items)? nextFeedBatchRequestSucceeded,
      TResult Function(FeedFailureReason reason, String? errors)?
          nextFeedBatchRequestFailed,
      TResult Function()? nextFeedBatchAvailable,
      TResult Function(Set<Source> excludedSources)?
          excludedSourcesListRequestSucceeded,
      TResult Function()? excludedSourcesListRequestFailed,
      TResult Function(Set<Source> sources)? trustedSourcesListRequestSucceeded,
      TResult Function()? trustedSourcesListRequestFailed,
      TResult Function(List<AvailableSource> availableSources)?
          availableSourcesListRequestSucceeded,
      TResult Function()? availableSourcesListRequestFailed,
      TResult Function()? fetchingAssetsStarted,
      TResult Function(double percentage)? fetchingAssetsProgressed,
      TResult Function()? fetchingAssetsFinished,
      TResult Function()? clientEventSucceeded,
      TResult Function()? resetAiSucceeded,
      TResult Function(EngineExceptionReason reason, String? message,
              String? stackTrace)?
          engineExceptionRaised,
      TResult Function(List<Document> items)? documentsUpdated,
      TResult Function(ActiveSearch search, List<Document> items)?
          activeSearchRequestSucceeded,
      TResult Function(SearchFailureReason reason)? activeSearchRequestFailed,
      TResult Function(ActiveSearch search, List<Document> items)?
          nextActiveSearchBatchRequestSucceeded,
      TResult Function(SearchFailureReason reason)?
          nextActiveSearchBatchRequestFailed,
      TResult Function(ActiveSearch search, List<Document> items)?
          restoreActiveSearchSucceeded,
      TResult Function(SearchFailureReason reason)? restoreActiveSearchFailed,
      TResult Function(String searchTerm)? activeSearchTermRequestSucceeded,
      TResult Function(SearchFailureReason reason)?
          activeSearchTermRequestFailed,
      TResult Function(List<Document> items)? deepSearchRequestSucceeded,
      TResult Function(SearchFailureReason reason)? deepSearchRequestFailed,
      TResult Function(List<TrendingTopic> topics)?
          trendingTopicsRequestSucceeded,
      TResult Function(SearchFailureReason reason)? trendingTopicsRequestFailed,
      required TResult Function() orElse}) {
    // TODO: implement maybeWhen
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  TResult when<TResult extends Object?>(
      {required TResult Function(List<Document> items) restoreFeedSucceeded,
      required TResult Function(FeedFailureReason reason) restoreFeedFailed,
      required TResult Function(List<Document> items)
          nextFeedBatchRequestSucceeded,
      required TResult Function(FeedFailureReason reason, String? errors)
          nextFeedBatchRequestFailed,
      required TResult Function() nextFeedBatchAvailable,
      required TResult Function(Set<Source> excludedSources)
          excludedSourcesListRequestSucceeded,
      required TResult Function() excludedSourcesListRequestFailed,
      required TResult Function(Set<Source> sources)
          trustedSourcesListRequestSucceeded,
      required TResult Function() trustedSourcesListRequestFailed,
      required TResult Function(List<AvailableSource> availableSources)
          availableSourcesListRequestSucceeded,
      required TResult Function() availableSourcesListRequestFailed,
      required TResult Function() fetchingAssetsStarted,
      required TResult Function(double percentage) fetchingAssetsProgressed,
      required TResult Function() fetchingAssetsFinished,
      required TResult Function() clientEventSucceeded,
      required TResult Function() resetAiSucceeded,
      required TResult Function(
              EngineExceptionReason reason, String? message, String? stackTrace)
          engineExceptionRaised,
      required TResult Function(List<Document> items) documentsUpdated,
      required TResult Function(ActiveSearch search, List<Document> items)
          activeSearchRequestSucceeded,
      required TResult Function(SearchFailureReason reason)
          activeSearchRequestFailed,
      required TResult Function(ActiveSearch search, List<Document> items)
          nextActiveSearchBatchRequestSucceeded,
      required TResult Function(SearchFailureReason reason)
          nextActiveSearchBatchRequestFailed,
      required TResult Function(ActiveSearch search, List<Document> items)
          restoreActiveSearchSucceeded,
      required TResult Function(SearchFailureReason reason)
          restoreActiveSearchFailed,
      required TResult Function(String searchTerm)
          activeSearchTermRequestSucceeded,
      required TResult Function(SearchFailureReason reason)
          activeSearchTermRequestFailed,
      required TResult Function(List<Document> items)
          deepSearchRequestSucceeded,
      required TResult Function(SearchFailureReason reason)
          deepSearchRequestFailed,
      required TResult Function(List<TrendingTopic> topics)
          trendingTopicsRequestSucceeded,
      required TResult Function(SearchFailureReason reason)
          trendingTopicsRequestFailed}) {
    // TODO: implement when
    throw UnimplementedError();
  }

  @override
  TResult? whenOrNull<TResult extends Object?>(
      {TResult Function(List<Document> items)? restoreFeedSucceeded,
      TResult Function(FeedFailureReason reason)? restoreFeedFailed,
      TResult Function(List<Document> items)? nextFeedBatchRequestSucceeded,
      TResult Function(FeedFailureReason reason, String? errors)?
          nextFeedBatchRequestFailed,
      TResult Function()? nextFeedBatchAvailable,
      TResult Function(Set<Source> excludedSources)?
          excludedSourcesListRequestSucceeded,
      TResult Function()? excludedSourcesListRequestFailed,
      TResult Function(Set<Source> sources)? trustedSourcesListRequestSucceeded,
      TResult Function()? trustedSourcesListRequestFailed,
      TResult Function(List<AvailableSource> availableSources)?
          availableSourcesListRequestSucceeded,
      TResult Function()? availableSourcesListRequestFailed,
      TResult Function()? fetchingAssetsStarted,
      TResult Function(double percentage)? fetchingAssetsProgressed,
      TResult Function()? fetchingAssetsFinished,
      TResult Function()? clientEventSucceeded,
      TResult Function()? resetAiSucceeded,
      TResult Function(EngineExceptionReason reason, String? message,
              String? stackTrace)?
          engineExceptionRaised,
      TResult Function(List<Document> items)? documentsUpdated,
      TResult Function(ActiveSearch search, List<Document> items)?
          activeSearchRequestSucceeded,
      TResult Function(SearchFailureReason reason)? activeSearchRequestFailed,
      TResult Function(ActiveSearch search, List<Document> items)?
          nextActiveSearchBatchRequestSucceeded,
      TResult Function(SearchFailureReason reason)?
          nextActiveSearchBatchRequestFailed,
      TResult Function(ActiveSearch search, List<Document> items)?
          restoreActiveSearchSucceeded,
      TResult Function(SearchFailureReason reason)? restoreActiveSearchFailed,
      TResult Function(String searchTerm)? activeSearchTermRequestSucceeded,
      TResult Function(SearchFailureReason reason)?
          activeSearchTermRequestFailed,
      TResult Function(List<Document> items)? deepSearchRequestSucceeded,
      TResult Function(SearchFailureReason reason)? deepSearchRequestFailed,
      TResult Function(List<TrendingTopic> topics)?
          trendingTopicsRequestSucceeded,
      TResult Function(SearchFailureReason reason)?
          trendingTopicsRequestFailed}) {
    // TODO: implement whenOrNull
    throw UnimplementedError();
  }
}
