import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/engine_events_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/engine_exception_raised_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/next_search_batch_request_failed_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/restore_search_failed_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/fetch_card_index_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/update_card_index_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/base_discovery_manager.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/discovery_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/search_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

typedef OnSearchRequestSucceeded = Set<Document> Function(
    SearchRequestSucceeded event);
typedef OnRestoreSearchSucceeded = Set<Document> Function(
    RestoreSearchSucceeded event);
typedef OnNextSearchBatchRequestSucceeded = Set<Document> Function(
    NextSearchBatchRequestSucceeded event);
typedef OnNextSearchBatchRequestFailed = Set<Document> Function(
    NextSearchBatchRequestFailed event);
typedef OnRestoreSearchFailed = Set<Document> Function(
    RestoreSearchFailed event);

abstract class ActiveSearchNavActions {
  void onHomeNavPressed();

  void onPersonalAreaNavPressed();

  void onCardDetailsPressed(DiscoveryCardStandaloneArgs args);
}

/// Manages the state for the active search screen.
///
/// It consumes events from the discovery engine and emits a state
/// which contains a list of discovery news items which should be displayed
/// in a list format by widgets.
@injectable
class ActiveSearchManager extends BaseDiscoveryManager
    with SearchMixin<DiscoveryState>
    implements ActiveSearchNavActions {
  ActiveSearchManager(
    this._activeSearchNavActions,
    EngineEventsUseCase engineEventsUseCase,
    FetchCardIndexUseCase fetchCardIndexUseCase,
    UpdateCardIndexUseCase updateCardIndexUseCase,
    SendAnalyticsUseCase sendAnalyticsUseCase,
    CrudExplicitDocumentFeedbackUseCase crudExplicitDocumentFeedbackUseCase,
    HapticFeedbackMediumUseCase hapticFeedbackMediumUseCase,
  ) : super(
          FeedType.search,
          engineEventsUseCase,
          _foldEngineEvent,
          fetchCardIndexUseCase,
          updateCardIndexUseCase,
          sendAnalyticsUseCase,
          crudExplicitDocumentFeedbackUseCase,
          hapticFeedbackMediumUseCase,
        );

  final ActiveSearchNavActions _activeSearchNavActions;
  bool _isLoading = true;
  bool _didReachEnd = false;

  @override
  bool get isLoading => _isLoading;

  @override
  bool get didReachEnd => _didReachEnd;

  void handleSearchTerm(String searchTerm) => scheduleComputeState(() {
        _isLoading = true;
        _didReachEnd = false;
        resetCardIndex();

        search(searchTerm);
      });

  @override
  void resetParameters() {
    resetCardIndex();
    // clears the current pending observation, if any...
    observeDocument();
    // clear the inner-stored current observation...
    resetObservedDocument();
  }

  @override
  void onPersonalAreaNavPressed() =>
      _activeSearchNavActions.onPersonalAreaNavPressed();

  @override
  void onHomeNavPressed() => _activeSearchNavActions.onHomeNavPressed();

  void onSearchNavPressed() {
    // TODO probably go to the top of the feed
  }

  @override
  void onCardDetailsPressed(DiscoveryCardStandaloneArgs args) =>
      _activeSearchNavActions.onCardDetailsPressed(args);

  @override
  void handleLoadMore() {
    if (_didReachEnd) return;

    requestNextSearchBatch();
  }

  static Set<Document> Function(EngineEvent?) _foldEngineEvent(
      BaseDiscoveryManager manager) {
    final self = manager as ActiveSearchManager;
    final state = manager.state;

    foldEngineEvent({
      required OnSearchRequestSucceeded searchRequestSucceeded,
      required OnRestoreSearchSucceeded restoreSearchSucceeded,
      required OnNextSearchBatchRequestSucceeded
          nextSearchBatchRequestSucceeded,
      required OnDocumentsUpdated documentsUpdated,
      required OnEngineExceptionRaised engineExceptionRaised,
      required OnNextSearchBatchRequestFailed nextSearchBatchRequestFailed,
      required OnRestoreSearchFailed restoreSearchFailed,
      required OnNonMatchedEngineEvent orElse,
    }) =>
        (EngineEvent? event) {
          if (event is SearchRequestSucceeded) {
            self._isLoading = false;
            return searchRequestSucceeded(event);
          } else if (event is RestoreSearchSucceeded) {
            self._isLoading = false;
            return restoreSearchSucceeded(event);
          } else if (event is NextSearchBatchRequestSucceeded) {
            self._isLoading = false;
            self._didReachEnd = event.items.isEmpty;
            return nextSearchBatchRequestSucceeded(event);
          } else if (event is DocumentsUpdated) {
            return documentsUpdated(event);
          } else if (event is EngineExceptionRaised) {
            return engineExceptionRaised(event);
          } else if (event is NextSearchBatchRequestFailed) {
            self._isLoading = false;
            return nextSearchBatchRequestFailed(event);
          } else if (event is RestoreSearchFailed) {
            self._isLoading = false;
            return restoreSearchFailed(event);
          }

          return orElse();
        };

    return foldEngineEvent(
      searchRequestSucceeded: (event) => event.items.toSet(),
      restoreSearchSucceeded: (event) => event.items.toSet(),
      nextSearchBatchRequestSucceeded: (event) =>
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
      nextSearchBatchRequestFailed: (event) {
        manager.sendAnalyticsUseCase(
          NextSearchBatchRequestFailedEvent(
            event: event,
          ),
        );

        logger.e('$event');

        return state.results;
      },
      restoreSearchFailed: (event) {
        manager.sendAnalyticsUseCase(
          RestoreSearchFailedEvent(
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
