import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/discovery_card_observation.dart';
import 'package:xayn_discovery_app/domain/model/document/document_feedback_context.dart';
import 'package:xayn_discovery_app/domain/model/document/explicit_document_feedback.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/document_index_changed_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/document_view_mode_changed_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/engine_exception_raised_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/next_feed_batch_request_failed_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/fetch_card_index_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/update_card_index_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/change_document_feedback_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/close_feed_documents_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/engine_events_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/observe_document_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/request_feed_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/widget/discovery_feed.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

typedef OnRestoreFeedSucceeded = Set<Document> Function(
    RestoreFeedSucceeded event);
typedef OnNextFeedBatchRequestSucceeded = Set<Document> Function(
    NextFeedBatchRequestSucceeded event);
typedef OnDocumentsUpdated = Set<Document> Function(DocumentsUpdated event);
typedef OnEngineExceptionRaised = Set<Document> Function(
    EngineExceptionRaised event);
typedef OnNextFeedBatchRequestFailed = Set<Document> Function(
    NextFeedBatchRequestFailed event);
typedef OnNonMatchedEngineEvent = Set<Document> Function();

const int _kMaxCardCount = 10;

/// a threshold, how long a user should observe a document, before it becomes
/// implicitly liked.
const int _kThresholdDurationSecondsImplicitLike = 5;

/// Manages the state for the main, or home discovery feed screen.
///
/// It consumes events from the discovery engine and emits a state
/// which contains a list of discovery news items which should be displayed
/// in a list format by widgets.
@injectable
class DiscoveryFeedManager extends Cubit<DiscoveryFeedState>
    with
        UseCaseBlocHelper<DiscoveryFeedState>,
        EngineEventsMixin<DiscoveryFeedState>,
        RequestFeedMixin<DiscoveryFeedState>,
        CloseFeedDocumentsMixin,
        ObserveDocumentMixin<DiscoveryFeedState>,
        ChangeUserReactionMixin<DiscoveryFeedState>
    implements DiscoveryFeedNavActions {
  DiscoveryFeedManager(
    this._discoveryFeedNavActions,
    this._fetchCardIndexUseCase,
    this._updateCardIndexUseCase,
    this._sendAnalyticsUseCase,
    this._crudExplicitDocumentFeedbackUseCase,
  )   : _maxCardCount = _kMaxCardCount,
        super(DiscoveryFeedState.initial());

  /// The max card count of the feed
  /// If the count overflows, then n-cards will be removed from the beginning
  /// onwards, until maxCardCount is satisfied.
  final int _maxCardCount;
  final DiscoveryFeedNavActions _discoveryFeedNavActions;
  final FetchCardIndexUseCase _fetchCardIndexUseCase;
  final UpdateCardIndexUseCase _updateCardIndexUseCase;
  final SendAnalyticsUseCase _sendAnalyticsUseCase;
  final CrudExplicitDocumentFeedbackUseCase
      _crudExplicitDocumentFeedbackUseCase;

  late final UseCaseValueStream<int> _cardIndexConsumer =
      consume(_fetchCardIndexUseCase, initialData: none)
          .transform((out) => out.take(1));

  /// When explicit feedback changes, we need to emit a new state,
  /// so that the feed can redraw like/dislike borders.
  /// This consumer watches all the active feed Documents.
  late final UseCaseValueStream<ExplicitDocumentFeedback>
      _crudExplicitDocumentFeedbackConsumer = consume(
    _crudExplicitDocumentFeedbackUseCase,
    initialData: CrudExplicitDocumentFeedbackUseCaseIn.watchAll(),
  );

  /// A weak-reference map which tracks the current [DocumentViewMode] of documents.
  final _documentCurrentViewMode = Expando<DocumentViewMode>();
  Document? _observedDocument;
  int? _cardIndex;
  bool _isFullScreen = false;

  void handleNavigateIntoCard() {
    scheduleComputeState(() => _isFullScreen = true);

    _sendAnalyticsUseCase(DocumentViewModeChangedEvent(
      document: _observedDocument!,
      viewMode: DocumentViewMode.reader,
    ));
  }

  void handleNavigateOutOfCard() {
    scheduleComputeState(() => _isFullScreen = false);

    _sendAnalyticsUseCase(DocumentViewModeChangedEvent(
      document: _observedDocument!,
      viewMode: DocumentViewMode.story,
    ));
  }

  /// Trigger this handler whenever the primary card changes.
  /// The [index] correlates with the index of the current primary card.
  void handleIndexChanged(int index) async {
    if (index >= state.results.length) return;

    final nextDocument = state.results.elementAt(index);
    final nextCardIndex = await _updateCardIndexUseCase.singleOutput(index);
    final didSwipeBefore = _cardIndex != null && _observedDocument != null;
    final direction = didSwipeBefore
        ? _cardIndex! < index
            ? Direction.down
            : Direction.up
        : Direction.start;

    observeDocument(
      document: nextDocument,
      mode: _currentViewMode(nextDocument.documentId),
      onObservation: _onObservation,
    );

    _sendAnalyticsUseCase(DocumentIndexChangedEvent(
      next: nextDocument,
      previous: _observedDocument,
      direction: direction,
    ));

    scheduleComputeState(() {
      _cardIndex = nextCardIndex;
      _observedDocument = nextDocument;
    });
  }

  /// Triggers a new observation for [document], if that document matches
  /// the last known inner document (secondary cards may also trigger).
  /// Use [viewType] to indicate the current view of that same document.
  void handleViewType(Document document, DocumentViewMode mode) {
    final activeMode = _currentViewMode(document.documentId);

    _documentCurrentViewMode[document.documentId] = mode;

    if (document.documentId == _observedDocument?.documentId &&
        activeMode != mode) {
      observeDocument(
        document: document,
        mode: mode,
        onObservation: _onObservation,
      );
    }
  }

  /// Handles moving the app between foreground and background.
  ///
  /// When the app moves into the background
  /// - we stop observing the last known card
  ///
  /// When the app moves into the foreground
  /// - we trigger a new observation with the last known card details
  void handleActivityStatus(bool isAppInForeground) {
    final observedDocument = _observedDocument;

    if (observedDocument == null) return;

    observeDocument(
      document: isAppInForeground ? observedDocument : null,
      mode: isAppInForeground
          ? _currentViewMode(observedDocument.documentId)
          : null,
      onObservation: _onObservation,
    );
  }

  /// Triggers the fake discovery engine to load more results, using a random
  /// keyword which is derived from the current result set.
  void handleLoadMore() async {
    requestNextFeedBatch();
  }

  @override
  Future<DiscoveryFeedState?> computeState() async => fold3(
        _cardIndexConsumer,
        _crudExplicitDocumentFeedbackConsumer,
        engineEvents,
      ).foldAll((
        cardIndex,
        explicitDocumentFeedback,
        engineEvent,
        errorReport,
      ) async {
        _cardIndex ??= cardIndex;

        if (_cardIndex == null) return null;

        final foldEngineEvent = _foldEngineEvent(engineEvent);

        final results = foldEngineEvent(
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
            _sendAnalyticsUseCase(EngineExceptionRaisedEvent(
              event: event,
            ));

            logger.e('$event');

            return state.results;
          },
          nextFeedBatchRequestFailed: (event) {
            _sendAnalyticsUseCase(NextFeedBatchRequestFailedEvent(
              event: event,
            ));

            logger.e('$event');

            return state.results;
          },
          orElse: () => state.results,
        );

        final sets = await _maybeReduceCardCount(results);

        final hasIsFullScreenChanged = state.isFullScreen != _isFullScreen;
        final hasExplicitDocumentFeedbackChanged =
            state.latestExplicitDocumentFeedback != explicitDocumentFeedback;

        final nextState = DiscoveryFeedState(
          results: sets.results,
          removedResults: sets.removedResults,
          isComplete: !isLoading,
          isInErrorState: errorReport.isNotEmpty,
          isFullScreen: _isFullScreen,
          cardIndex: _cardIndex!,
          latestExplicitDocumentFeedback: explicitDocumentFeedback,
          shouldUpdateNavBar:
              hasIsFullScreenChanged || hasExplicitDocumentFeedbackChanged,
        );

        // guard against same-state emission
        if (!nextState.equals(state)) return nextState;
      });

  Set<Document> Function({
    required OnRestoreFeedSucceeded restoreFeedSucceeded,
    required OnNextFeedBatchRequestSucceeded nextFeedBatchRequestSucceeded,
    required OnDocumentsUpdated documentsUpdated,
    required OnEngineExceptionRaised engineExceptionRaised,
    required OnNextFeedBatchRequestFailed nextFeedBatchRequestFailed,
    required OnNonMatchedEngineEvent orElse,
  }) _foldEngineEvent(EngineEvent? event) => ({
        required OnRestoreFeedSucceeded restoreFeedSucceeded,
        required OnNextFeedBatchRequestSucceeded nextFeedBatchRequestSucceeded,
        required OnDocumentsUpdated documentsUpdated,
        required OnEngineExceptionRaised engineExceptionRaised,
        required OnNextFeedBatchRequestFailed nextFeedBatchRequestFailed,
        required OnNonMatchedEngineEvent orElse,
      }) {
        if (event is RestoreFeedSucceeded) {
          return restoreFeedSucceeded(event);
        } else if (event is NextFeedBatchRequestSucceeded) {
          return nextFeedBatchRequestSucceeded(event);
        } else if (event is DocumentsUpdated) {
          return documentsUpdated(event);
        } else if (event is EngineExceptionRaised) {
          return engineExceptionRaised(event);
        } else if (event is NextFeedBatchRequestFailed) {
          return nextFeedBatchRequestFailed(event);
        }

        return orElse();
      };

  DocumentViewMode _currentViewMode(DocumentId id) =>
      _documentCurrentViewMode[id] ?? DocumentViewMode.story;

  Future<ResultSets> _maybeReduceCardCount(Set<Document> results) async {
    final observedDocument = _observedDocument;

    if (observedDocument == null || results.length <= _maxCardCount) {
      return ResultSets(results: results);
    }

    var nextResults = results.toSet();
    var cardIndex = _cardIndex!;
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
    _cardIndex = await _updateCardIndexUseCase
        .singleOutput(cardIndex.clamp(0, nextResults.length - 1));

    return ResultSets(
      results: nextResults,
      removedResults: flaggedForDisposal,
    );
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

  void onHomeNavPressed() {
    // TODO probably go to the top of the feed
  }

  /// secondary observation action, check if we should implicitly like the [Document]
  void _onObservation(DiscoveryCardMeasuredObservation observation) {
    final document = observation.document!;
    final isCardOpened = observation.viewType != DocumentViewMode.story;
    final isObservedLongEnough = observation.duration.inSeconds >=
        _kThresholdDurationSecondsImplicitLike;

    if (isCardOpened && isObservedLongEnough) {
      changeUserReaction(
        document: document,
        userReaction: UserReaction.positive,
        context: FeedbackContext.implicit,
      );
    }
  }
}

class ResultSets {
  final Set<Document> results;
  final Set<Document> removedResults;

  const ResultSets({
    required this.results,
    this.removedResults = const <Document>{},
  });
}
