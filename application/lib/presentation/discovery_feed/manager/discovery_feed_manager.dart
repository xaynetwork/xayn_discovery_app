import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/engine_exception_raised_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/next_feed_batch_request_failed_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/restore_feed_failed.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/fetch_card_index_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/update_card_index_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/base_discovery_manager.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/discovery_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/close_feed_documents_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/request_feed_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
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
}

/// Manages the state for the main, or home discovery feed screen.
///
/// It consumes events from the discovery engine and emits a state
/// which contains a list of discovery news items which should be displayed
/// in a list format by widgets.
@injectable
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
    this._discoveryFeedNavActions,
    FetchCardIndexUseCase fetchCardIndexUseCase,
    UpdateCardIndexUseCase updateCardIndexUseCase,
    SendAnalyticsUseCase sendAnalyticsUseCase,
    CrudExplicitDocumentFeedbackUseCase crudExplicitDocumentFeedbackUseCase,
    HapticFeedbackMediumUseCase hapticFeedbackMediumUseCase,
  )   : _maxCardCount = _kMaxCardCount,
        super(
          _foldEngineEvent,
          fetchCardIndexUseCase,
          updateCardIndexUseCase,
          sendAnalyticsUseCase,
          crudExplicitDocumentFeedbackUseCase,
          hapticFeedbackMediumUseCase,
        );

  final DiscoveryFeedNavActions _discoveryFeedNavActions;

  bool _didChangeMarkets = false;
  bool _isLoading = true;

  @override
  bool get isLoading => _isLoading;

  @override
  Future<ResultSets> maybeReduceCardCount(Set<Document> results) async {
    final observedDocument = currentObservedDocument;

    if (observedDocument == null || results.length <= _maxCardCount) {
      return ResultSets(results: results);
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
      return ResultSets(results: results);
    }

    // Invoke the use case which closes these Documents for the engine
    // ok to be fire and forget, should we instead wait for the ack,
    // then we need a specific CloseDocumentEngineEvent.
    // Currently, we just get a generic [ClientEventSucceeded] event only.
    closeFeedDocuments(flaggedForDisposal.map((it) => it.documentId).toSet());
    // adjust the cardIndex to counter the removals
    cardIndex = await updateCardIndexUseCase
        .singleOutput(cardIndex.clamp(0, nextResults.length - 1));

    return ResultSets(
      nextCardIndex: cardIndex,
      results: nextResults,
      removedResults: flaggedForDisposal,
    );
  }

  @override
  void willChangeMarkets() => scheduleComputeState(() {
        super.willChangeMarkets();
        // closes the current feed...
        closeFeedDocuments(state.results.map((it) => it.documentId).toSet());
      });

  /// Triggers the discovery engine to load more results.
  @override
  void handleLoadMore() => requestNextFeedBatch();

  /// Configuration was updated, we now ask for fresh documents, under the
  /// new market settings.
  @override
  void didChangeMarkets() => requestNextFeedBatch();

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
  Future<DiscoveryState?> computeState() async {
    if (_didChangeMarkets) {
      _didChangeMarkets = false;

      return state.copyWith(results: const <Document>{});
    }

    return super.computeState();
  }

  static Set<Document> Function(EngineEvent?) _foldEngineEvent(
      BaseDiscoveryManager manager) {
    final self = manager as DiscoveryFeedManager;
    final state = manager.state;

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
          if (event is RestoreFeedSucceeded) {
            self._isLoading = false;
            return restoreFeedSucceeded(event);
          } else if (event is NextFeedBatchRequestSucceeded) {
            self._isLoading = false;
            return nextFeedBatchRequestSucceeded(event);
          } else if (event is DocumentsUpdated) {
            return documentsUpdated(event);
          } else if (event is EngineExceptionRaised) {
            return engineExceptionRaised(event);
          } else if (event is NextFeedBatchRequestFailed) {
            self._isLoading = false;
            return nextFeedBatchRequestFailed(event);
          } else if (event is RestoreFeedFailed) {
            self._isLoading = false;
            return restoreFeedFailed(event);
          }

          return orElse();
        };

    return foldEngineEvent(
      restoreFeedSucceeded: (event) => {...state.results, ...event.items},
      nextFeedBatchRequestSucceeded: (event) =>
          {...state.results, ...event.items},
      documentsUpdated: (event) => state.results
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
          ),
        );

        logger.e('$event');

        return state.results;
      },
      nextFeedBatchRequestFailed: (event) {
        manager.sendAnalyticsUseCase(
          NextFeedBatchRequestFailedEvent(
            event: event,
          ),
        );

        logger.e('$event');

        return state.results;
      },
      restoreFeedFailed: (event) {
        manager.sendAnalyticsUseCase(
          RestoreFeedFailedEvent(
            event: event,
          ),
        );

        logger.e('$event');

        return state.results;
      },
      orElse: () => state.results,
    );
  }
}
