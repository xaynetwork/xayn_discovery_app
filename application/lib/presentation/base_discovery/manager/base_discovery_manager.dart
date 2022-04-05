import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/discovery_card_observation.dart';
import 'package:xayn_discovery_app/domain/model/document/document_feedback_context.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/engine_events_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/document_index_changed_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/document_view_mode_changed_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_subscription_window_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/reader_mode_settings_menu_displayed_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/fetch_card_index_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/update_card_index_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/listen_reader_mode_settings_use_case.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/discovery_state.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/change_document_feedback_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/observe_document_mixin.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

typedef OnDocumentsUpdated = Set<Document> Function(DocumentsUpdated event);
typedef OnEngineExceptionRaised = Set<Document> Function(
    EngineExceptionRaised event);
typedef OnNonMatchedEngineEvent = Set<Document> Function();
typedef FoldEngineEvent = Set<Document> Function(EngineEvent?) Function(
    BaseDiscoveryManager);

/// a threshold, how long a user should observe a document, before it becomes
/// implicitly liked.
const int _kThresholdDurationSecondsImplicitLike = 5;

/// Manages the state for the main, or home discovery feed screen.
///
/// It consumes events from the discovery engine and emits a state
/// which contains a list of discovery news items which should be displayed
/// in a list format by widgets.
abstract class BaseDiscoveryManager extends Cubit<DiscoveryState>
    with
        UseCaseBlocHelper<DiscoveryState>,
        ObserveDocumentMixin<DiscoveryState>,
        ChangeUserReactionMixin<DiscoveryState> {
  final EngineEventsUseCase engineEventsUseCase;
  final FoldEngineEvent foldEngineEvent;
  final FetchCardIndexUseCase fetchCardIndexUseCase;
  final UpdateCardIndexUseCase updateCardIndexUseCase;
  final SendAnalyticsUseCase sendAnalyticsUseCase;
  final CrudExplicitDocumentFeedbackUseCase crudExplicitDocumentFeedbackUseCase;
  final HapticFeedbackMediumUseCase hapticFeedbackMediumUseCase;
  final GetSubscriptionStatusUseCase getSubscriptionStatusUseCase;
  final ListenReaderModeSettingsUseCase listenReaderModeSettingsUseCase;
  final FeatureManager featureManager;
  final FeedType feedType;

  /// A weak-reference map which tracks the current [DocumentViewMode] of documents.
  final _documentCurrentViewMode = Expando<DocumentViewMode>();
  Document? _observedDocument;
  int? _cardIndex;
  bool _isFullScreen = false;

  BaseDiscoveryManager(
    this.feedType,
    this.engineEventsUseCase,
    this.foldEngineEvent,
    this.fetchCardIndexUseCase,
    this.updateCardIndexUseCase,
    this.sendAnalyticsUseCase,
    this.crudExplicitDocumentFeedbackUseCase,
    this.hapticFeedbackMediumUseCase,
    this.getSubscriptionStatusUseCase,
    this.listenReaderModeSettingsUseCase,
    this.featureManager,
  ) : super(DiscoveryState.initial());

  late final UseCaseValueStream<EngineEvent> engineEvents = consume(
    engineEventsUseCase,
    initialData: none,
  );
  late final UseCaseValueStream<int> cardIndexConsumer =
      consume(fetchCardIndexUseCase, initialData: feedType)
          .transform((out) => out.take(1));

  late final UseCaseValueStream<ReaderModeSettings> _readerModeSettingsHandler =
      consume(
    listenReaderModeSettingsUseCase,
    initialData: none,
  );

  /// When explicit feedback changes, we need to emit a new state,
  /// so that the feed can redraw like/dislike borders.
  /// This consumer watches all the active feed Documents.
  late final crudExplicitDocumentFeedbackConsumer = consume(
    crudExplicitDocumentFeedbackUseCase,
    initialData: const DbCrudIn.watchAllChanged(),
  );

  late final UseCaseValueStream<SubscriptionStatus> subscriptionStatusHandler =
      consume(
    getSubscriptionStatusUseCase,
    initialData: PurchasableIds.subscription,
  ).transform(
    (out) => out
        .skipWhile((_) => !featureManager.isPaymentEnabled)
        .doOnData(handleShowPaywallIfNeeded),
  );

  /// requires to be implemented by concrete classes or mixins
  bool get isLoading;

  /// requires to be implemented by concrete classes or mixins
  bool get didReachEnd;

  Document? get currentObservedDocument => _observedDocument;

  int? get currentCardIndex => _cardIndex;

  void handleNavigateIntoCard(Document document) {
    scheduleComputeState(() => _isFullScreen = true);

    sendAnalyticsUseCase(DocumentViewModeChangedEvent(
      document: document,
      viewMode: DocumentViewMode.reader,
      feedType: feedType,
    ));
  }

  void handleNavigateOutOfCard(Document document) {
    scheduleComputeState(() => _isFullScreen = false);

    sendAnalyticsUseCase(DocumentViewModeChangedEvent(
      document: document,
      viewMode: DocumentViewMode.story,
      feedType: feedType,
    ));
  }

  void handleLoadMore();

  void handleShowPaywallIfNeeded(SubscriptionStatus subscriptionStatus);

  /// Trigger this handler whenever the primary card changes.
  /// The [index] correlates with the index of the current primary card.
  void handleIndexChanged(int index) async {
    if (index >= state.results.length) return;

    final nextDocument = state.results.elementAt(index);
    late final int nextCardIndex;

    switch (feedType) {
      case FeedType.feed:
        nextCardIndex = await updateCardIndexUseCase
            .singleOutput(FeedTypeAndIndex.feed(cardIndex: index));
        break;
      case FeedType.search:
        nextCardIndex = await updateCardIndexUseCase
            .singleOutput(FeedTypeAndIndex.search(cardIndex: index));
        break;
    }

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

    sendAnalyticsUseCase(DocumentIndexChangedEvent(
      next: nextDocument,
      direction: direction,
      feedType: feedType,
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

  void resetCardIndex([int nextCardIndex = 0]) => _cardIndex = nextCardIndex;

  void resetObservedDocument() => _observedDocument = null;

  @override
  bool isDocumentCurrentlyDisplayed(Document document) =>
      state.results.map((it) => it.documentId).contains(document.documentId);

  /// override this method, if your view needs to dispose older items, as
  /// the total results grow in size
  Future<ResultSets> maybeReduceCardCount(Set<Document> results) async =>
      ResultSets(results: results);

  void triggerHapticFeedbackMedium() => hapticFeedbackMediumUseCase.call(none);

  void onReaderModeMenuDisplayed({required bool isVisible}) =>
      sendAnalyticsUseCase(
        ReaderModeSettingsMenuDisplayedEvent(
          isVisible: isVisible,
          feedType: feedType,
        ),
      );

  @override
  Future<DiscoveryState?> computeState() async => fold5(
        cardIndexConsumer,
        crudExplicitDocumentFeedbackConsumer,
        engineEvents,
        subscriptionStatusHandler,
        _readerModeSettingsHandler,
      ).foldAll((
        cardIndex,
        explicitDocumentFeedback,
        engineEvent,
        subscriptionStatus,
        readerModeSettings,
        errorReport,
      ) async {
        _cardIndex ??= cardIndex;

        if (_cardIndex == null) return null;

        final results = foldEngineEvent(this)(engineEvent);
        final isInErrorState =
            errorReport.isNotEmpty || engineEvent is EngineExceptionRaised;
        final sets = await maybeReduceCardCount(results);
        final nextCardIndex = sets.nextCardIndex;

        if (nextCardIndex != null) _cardIndex = nextCardIndex;

        final hasIsFullScreenChanged = state.isFullScreen != _isFullScreen;
        final feedback =
            explicitDocumentFeedback?.mapOrNull(single: (v) => v.value);
        final hasExplicitDocumentFeedbackChanged =
            state.latestExplicitDocumentFeedback != feedback;
        final nextState = DiscoveryState(
          results: sets.results,
          removedResults: sets.removedResults,
          isComplete: !isLoading,
          isInErrorState: isInErrorState,
          isFullScreen: _isFullScreen,
          didReachEnd: didReachEnd,
          cardIndex: _cardIndex!,
          latestExplicitDocumentFeedback: feedback,
          shouldUpdateNavBar:
              hasIsFullScreenChanged || hasExplicitDocumentFeedbackChanged,
          subscriptionStatus: subscriptionStatus,
          readerModeBackgroundColor:
              _isFullScreen ? readerModeSettings?.backgroundColor : null,
        );

        // guard against same-state emission
        if (!nextState.equals(state)) return nextState;
      });

  DocumentViewMode _currentViewMode(DocumentId id) =>
      _documentCurrentViewMode[id] ?? DocumentViewMode.story;

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

  void onTrialBannerTapped() {
    sendAnalyticsUseCase(
      OpenSubscriptionWindowEvent(
        currentView: SubscriptionWindowCurrentView.feed,
      ),
    );
  }
}

class ResultSets {
  final int? nextCardIndex;
  final Set<Document> results;
  final Set<Document> removedResults;

  const ResultSets({
    required this.results,
    this.nextCardIndex,
    this.removedResults = const <Document>{},
  });
}
