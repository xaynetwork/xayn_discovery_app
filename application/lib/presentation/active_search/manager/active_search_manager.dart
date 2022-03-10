import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/restore_search_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/engine_exception_raised_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/next_search_batch_request_failed_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/fetch_card_index_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/update_card_index_use_case.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/base_discovery_manager.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/discovery_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/close_search_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/search_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

typedef OnRestoreSearchSucceeded = Set<Document> Function(
    RestoreSearchSucceeded event);
typedef OnNextSearchBatchRequestSucceeded = Set<Document> Function(
    NextSearchBatchRequestSucceeded event);
typedef OnNextSearchBatchRequestFailed = Set<Document> Function(
    NextSearchBatchRequestFailed event);

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
    with SearchMixin<DiscoveryState>, CloseSearchMixin<DiscoveryState>
    implements ActiveSearchNavActions {
  ActiveSearchManager(
    this._activeSearchNavActions,
    this._restoreSearchUseCase,
    FetchCardIndexUseCase fetchCardIndexUseCase,
    UpdateCardIndexUseCase updateCardIndexUseCase,
    SendAnalyticsUseCase sendAnalyticsUseCase,
    CrudExplicitDocumentFeedbackUseCase crudExplicitDocumentFeedbackUseCase,
  ) : super(
          _foldEngineEvent,
          fetchCardIndexUseCase,
          updateCardIndexUseCase,
          sendAnalyticsUseCase,
          crudExplicitDocumentFeedbackUseCase,
        );

  final RestoreSearchUseCase _restoreSearchUseCase;
  final ActiveSearchNavActions _activeSearchNavActions;

  @override
  void willChangeMarkets() => scheduleComputeState(() {
        super.willChangeMarkets();
        // closes the current search...
        closeSearch(state.results.map((it) => it.documentId).toSet());
      });

  void handleSearchTerm(String searchTerm) => search(searchTerm);

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
  void handleLoadMore() => requestNextSearchBatch();

  @override
  void didChangeMarkets() async {
    final engineEvent = await _restoreSearchUseCase.singleOutput(none);

    if (engineEvent is RestoreSearchSucceeded) {
      final queryTerm = engineEvent.search.queryTerm;

      handleSearchTerm(queryTerm);
    }
  }

  /// in search, we never reduce the cards...
  @override
  Future<ResultSets> maybeReduceCardCount(Set<Document> results) async =>
      ResultSets(results: results);

  static Set<Document> Function(EngineEvent?) _foldEngineEvent(
      BaseDiscoveryManager manager) {
    final state = manager.state;

    foldEngineEvent({
      required OnRestoreSearchSucceeded restoreSearchSucceeded,
      required OnNextSearchBatchRequestSucceeded
          nextSearchBatchRequestSucceeded,
      required OnDocumentsUpdated documentsUpdated,
      required OnEngineExceptionRaised engineExceptionRaised,
      required OnNextSearchBatchRequestFailed nextSearchBatchRequestFailed,
      required OnNonMatchedEngineEvent orElse,
    }) =>
        (EngineEvent? event) {
          if (event is RestoreSearchSucceeded) {
            return restoreSearchSucceeded(event);
          } else if (event is NextSearchBatchRequestSucceeded) {
            return nextSearchBatchRequestSucceeded(event);
          } else if (event is DocumentsUpdated) {
            return documentsUpdated(event);
          } else if (event is EngineExceptionRaised) {
            return engineExceptionRaised(event);
          } else if (event is NextSearchBatchRequestFailed) {
            return nextSearchBatchRequestFailed(event);
          }

          return orElse();
        };

    return foldEngineEvent(
      restoreSearchSucceeded: (event) => {...state.results, ...event.items},
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
      orElse: () => state.results,
    );
  }
}
