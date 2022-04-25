import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_type.dart';
import 'package:xayn_discovery_app/domain/model/session/session.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/engine_events_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/session_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/engine_exception_raised_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/next_feed_batch_request_failed_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/restore_feed_failed.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/fetch_card_index_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/update_card_index_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/listen_reader_mode_settings_use_case.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/base_discovery_manager.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/discovery_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/card_managers_cache.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/close_feed_documents_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/request_feed_mixin.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

const int _kMaxCardCount = 10;

typedef OnRestoreFeedSucceeded = Set<Document> Function(
    RestoreFeedSucceeded event);
typedef OnRestoreFeedFailed = Set<Document> Function(RestoreFeedFailed event);
typedef OnNextFeedBatchRequestSucceeded = Set<Document> Function(
    NextFeedBatchRequestSucceeded event);
typedef OnNextFeedBatchRequestFailed = Set<Document> Function(
    NextFeedBatchRequestFailed event);

abstract class DiscoveryFeedNavActions {
  void onSearchNavPressed();

  void onPersonalAreaNavPressed();

  void onTrialExpired();
}

/// Manages the state for the main, or home discovery feed screen.
///
/// It consumes events from the discovery engine and emits a state
/// which contains a list of discovery news items which should be displayed
/// in a list format by widgets.
@lazySingleton
class DiscoveryFeedManager extends BaseDiscoveryManager
    with
        RequestFeedMixin<DiscoveryState>,
        CloseFeedDocumentsMixin<DiscoveryState>
    implements DiscoveryFeedNavActions {
  /// The max card count of the feed
  /// If the count overflows, then n-cards will be removed from the beginning
  /// onwards, until maxCardCount is satisfied.
  final int _maxCardCount;

  DiscoveryFeedManager(
    this._fetchSessionUseCase,
    this._discoveryFeedNavActions,
    EngineEventsUseCase engineEventsUseCase,
    FetchCardIndexUseCase fetchCardIndexUseCase,
    UpdateCardIndexUseCase updateCardIndexUseCase,
    SendAnalyticsUseCase sendAnalyticsUseCase,
    CrudExplicitDocumentFeedbackUseCase crudExplicitDocumentFeedbackUseCase,
    HapticFeedbackMediumUseCase hapticFeedbackMediumUseCase,
    GetSubscriptionStatusUseCase getSubscriptionStatusUseCase,
    ListenReaderModeSettingsUseCase listenReaderModeSettingsUseCase,
    FeatureManager featureManager,
    CardManagersCache cardManagersCache,
  )   : _maxCardCount = _kMaxCardCount,
        super(
          FeedType.feed,
          engineEventsUseCase,
          _foldEngineEvent(),
          fetchCardIndexUseCase,
          updateCardIndexUseCase,
          sendAnalyticsUseCase,
          crudExplicitDocumentFeedbackUseCase,
          hapticFeedbackMediumUseCase,
          getSubscriptionStatusUseCase,
          listenReaderModeSettingsUseCase,
          featureManager,
          cardManagersCache,
        );

  late final FetchSessionUseCase _fetchSessionUseCase;
  final DiscoveryFeedNavActions _discoveryFeedNavActions;

  bool _isLoading = true;

  @override
  bool get isLoading => _isLoading;

  @override
  bool get didReachEnd => false;

  Future<Session> getSession() => _fetchSessionUseCase.singleOutput(none);

  @override
  Future<ResultSets> maybeReduceCardCount(Set<Document> results) async {
    final stateDiffResult = await super.maybeReduceCardCount(results);
    final observedDocument = currentObservedDocument;

    if (observedDocument == null || results.length <= _maxCardCount) {
      return ResultSets(
        results: results,
        removedResults: stateDiffResult.removedResults,
      );
    }

    var nextResults = results.toSet();
    var cardIndex = currentCardIndex!;
    final flaggedForDisposal =
        results.take(results.length - _maxCardCount).toSet();

    nextResults = nextResults..removeAll(flaggedForDisposal);
    cardIndex = nextResults.toList().indexOf(observedDocument);

    // The number 2 was chosen because we always animate transitions when
    // moving between cards.
    // If it is 2, then we have at least some cards above, and some cards below.
    // This is actually important, because a transition going from card A to card B
    // might currently be playing out:
    // If cardIndex would be 0 or 1, then that running animation might not play correctly:
    // the space above index 0 is zero, so there is no "from" range anymore
    // which was the starting value when the animation began.
    if (cardIndex <= 2) {
      // This means we are about to remove the Document that is currently
      // in front, which should be avoided.
      // Only remove documents when scrolled far enough, so that the impact
      // is seamless to the user.
      return ResultSets(
        results: results,
        removedResults: stateDiffResult.removedResults,
      );
    }

    // Invoke the use case which closes these Documents for the engine
    // ok to be fire and forget, should we instead wait for the ack,
    // then we need a specific CloseDocumentEngineEvent.
    // Currently, we just get a generic [ClientEventSucceeded] event only.
    final documentIdsToClose = flaggedForDisposal
        .map((it) => it.documentId)
        .toList()
      ..removeWhere(closedDocuments.contains);

    if (documentIdsToClose.isNotEmpty) {
      closeFeedDocuments(documentIdsToClose.toSet());
    }

    // adjust the cardIndex to counter the removals
    cardIndex = await updateCardIndexUseCase.singleOutput(
      FeedTypeAndIndex.feed(
        cardIndex: cardIndex.clamp(0, nextResults.length - 1),
      ),
    );

    return ResultSets(
      nextCardIndex: cardIndex,
      results: nextResults,
      removedResults: {
        ...flaggedForDisposal,
        ...stateDiffResult.removedResults,
      },
    );
  }

  /// Triggers the discovery engine to load more results.
  @override
  void handleLoadMore() => requestNextFeedBatch();

  void onHomeNavPressed() {
    // TODO probably go to the top of the feed
  }

  @override
  void onSearchNavPressed() {
    // detect that we exit the feed screen
    handleActivityStatus(false);

    _discoveryFeedNavActions.onSearchNavPressed();
  }

  @override
  void onPersonalAreaNavPressed() {
    // detect that we exit the feed screen
    handleActivityStatus(false);

    _discoveryFeedNavActions.onPersonalAreaNavPressed();
  }

  @override
  void onTrialExpired() => _discoveryFeedNavActions.onTrialExpired();

  @override
  void resetParameters([int nextCardIndex = 0]) {
    resetCardIndex(nextCardIndex);
    // clears the current pending observation, if any...
    observeDocument();
    // clear the inner-stored current observation...
    resetObservedDocument();
  }

  /// A higher-order Function, which tracks the last event passed in,
  /// and ultimately runs the inner fold Function when the incoming event
  /// no longer matches lastEvent.
  static Set<Document> Function(EngineEvent?) Function(BaseDiscoveryManager)
      _foldEngineEvent() {
    // because foldEngineEvent runs within a combineLatest setup,
    // we can use lastEvent to compare with the incoming event,
    // if they are the same, then the fold does not need to re-run.
    // this is important, because _isLoading would otherwise falsely be
    // switched to true.
    EngineEvent? lastEvent;
    var lastResults = const <Document>{};

    return (BaseDiscoveryManager manager) {
      final self = manager as DiscoveryFeedManager;

      if (self.closedDocuments.isNotEmpty) {
        // because the feed's state will remove the oldest card, when the
        // total card count is high enough, we replicate that action here.
        lastResults = lastResults.toSet()
          ..removeWhere((it) => self.closedDocuments.contains(it.documentId));
      }

      foldEngineEvent({
        required OnRestoreFeedSucceeded restoreFeedSucceeded,
        required OnNextFeedBatchRequestSucceeded nextFeedBatchRequestSucceeded,
        required OnDocumentsUpdated documentsUpdated,
        required OnEngineExceptionRaised engineExceptionRaised,
        required OnNextFeedBatchRequestFailed nextFeedBatchRequestFailed,
        required OnRestoreFeedFailed restoreFeedFailed,
        required OnNonMatchedEngineEvent orElse,
      }) =>
          (EngineEvent? event) {
            if (event == lastEvent) return lastResults;

            lastEvent = event;

            if (event is RestoreFeedSucceeded) {
              lastResults = restoreFeedSucceeded(event);
            } else if (event is NextFeedBatchRequestSucceeded) {
              self._isLoading = false;
              lastResults = nextFeedBatchRequestSucceeded(event);
            } else if (event is DocumentsUpdated) {
              lastResults = documentsUpdated(event);
            } else if (event is EngineExceptionRaised) {
              lastResults = engineExceptionRaised(event);
            } else if (event is NextFeedBatchRequestFailed) {
              self._isLoading = false;
              lastResults = nextFeedBatchRequestFailed(event);
            } else if (event is RestoreFeedFailed) {
              lastResults = restoreFeedFailed(event);
            } else {
              lastResults = orElse();
            }

            return lastResults;
          };

      return foldEngineEvent(
        restoreFeedSucceeded: (event) => event.items.toSet(),
        nextFeedBatchRequestSucceeded: (event) =>
            {...lastResults, ...event.items},
        documentsUpdated: (event) => lastResults
            .map(
              (it) => event.items.firstWhere(
                (item) => item.documentId == it.documentId,
                orElse: () => it,
              ),
            )
            .toSet(),
        engineExceptionRaised: (event) {
          manager.sendAnalyticsUseCase(
            EngineExceptionRaisedEvent(
              event: event,
              feedType: FeedType.feed,
            ),
          );

          logger.e('$event');

          return lastResults;
        },
        nextFeedBatchRequestFailed: (event) {
          manager.sendAnalyticsUseCase(
            NextFeedBatchRequestFailedEvent(
              event: event,
            ),
          );

          logger.e('$event');

          return lastResults;
        },
        restoreFeedFailed: (event) {
          manager.sendAnalyticsUseCase(
            RestoreFeedFailedEvent(
              event: event,
            ),
          );

          logger.e('$event');

          return lastResults;
        },
        orElse: () => lastResults,
      );
    };
  }

  @override
  void handleShowPaywallIfNeeded(SubscriptionStatus subscriptionStatus) {
    if (subscriptionStatus.subscriptionType == SubscriptionType.notSubscribed) {
      _discoveryFeedNavActions.onTrialExpired();
    }
  }
}
