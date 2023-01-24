import 'dart:async';
import 'dart:ui';

import 'package:dart_remote_config/utils/extensions.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/discovery_card_observation.dart';
import 'package:xayn_discovery_app/domain/model/document/document_feedback_context.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document_id.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document_view_mode.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/documents_updated.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/engine_event.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/engine_exception_raised.dart';
import 'package:xayn_discovery_app/domain/model/legacy/user_reaction.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/engine_events_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/fetch_card_index_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/update_card_index_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/listen_reader_mode_settings_use_case.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/discovery_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/card_managers_cache.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/check_valid_document_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/change_document_feedback_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/observe_document_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/singleton_subscription_observer.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager_mixin.dart';

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
        SingletonSubscriptionObserver<DiscoveryState>,
        ObserveDocumentMixin<DiscoveryState>,
        ChangeUserReactionMixin<DiscoveryState>,
        OverlayManagerMixin<DiscoveryState>,
        CheckValidDocumentMixin<DiscoveryState> {
  final EngineEventsUseCase engineEventsUseCase;
  final FoldEngineEvent foldEngineEvent;
  final FetchCardIndexUseCase fetchCardIndexUseCase;
  final UpdateCardIndexUseCase updateCardIndexUseCase;
  final CrudExplicitDocumentFeedbackUseCase crudExplicitDocumentFeedbackUseCase;
  final HapticFeedbackMediumUseCase hapticFeedbackMediumUseCase;
  final ListenReaderModeSettingsUseCase listenReaderModeSettingsUseCase;
  final FeatureManager featureManager;
  final FeedType feedType;
  final CardManagersCache cardManagersCache;

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
    this.crudExplicitDocumentFeedbackUseCase,
    this.hapticFeedbackMediumUseCase,
    this.listenReaderModeSettingsUseCase,
    this.featureManager,
    this.cardManagersCache,
  ) : super(DiscoveryState.initial());

  late final UseCaseValueStream<Set<Document>> cardStream = consume(
    engineEventsUseCase,
    initialData: none,
  ).transform(
    (out) => out.doOnData(onEngineEvent).map((it) => foldEngineEvent(this)(it)),
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

  /// requires to be implemented by concrete classes or mixins
  bool get isLoading;

  /// requires to be implemented by concrete classes or mixins
  bool get didReachEnd;

  Document? get currentObservedDocument => _observedDocument;

  int? get currentCardIndex => _cardIndex;

  void onEngineEvent(EngineEvent event);

  void maybeSelectCard(UniqueId documentId) {
    final card = state.cards.firstWhereOrNull(
        (card) => card.document.documentId.toString() == documentId.value);
    if (card == null) return;
    maybeNavigateIntoCard(card.document);
  }

  void maybeNavigateIntoCard(Document document) =>
      checkIfDocumentNotProcessable(
        document,
        onValid: () => handleNavigateIntoCard(document),
      );

  void handleNavigateIntoCard(Document document) {
    scheduleComputeState(() => _isFullScreen = true);
  }

  void handleNavigateOutOfCard(Document document) {
    scheduleComputeState(() => _isFullScreen = false);
  }

  void handleLoadMore();

  /// Trigger this handler whenever the primary card changes.
  /// The [index] correlates with the index of the current primary card.
  void handleIndexChanged(int index) async {
    if (index >= state.cards.length) return;

    final nextCard = state.cards.elementAt(index);
    final document = nextCard.document;
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

    observeDocument(
      document: document,
      mode: _currentViewMode(document.documentId),
    );

    scheduleComputeState(() {
      _cardIndex = nextCardIndex;
      _observedDocument = document;
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
    );
  }

  void resetCardIndex([int nextCardIndex = 0]) => _cardIndex = nextCardIndex;

  void resetObservedDocument() => _observedDocument = null;

  @override
  bool isDocumentCurrentlyDisplayed(Document document) => state.cards
      .where((it) => it.type == CardType.document)
      .map((it) => it.document)
      .map((it) => it.documentId)
      .contains(document.documentId);

  /// override this method, if your view needs to dispose older items, as
  /// the total results grow in size
  @mustCallSuper
  Future<ResultSets> maybeReduceCardCount(Set<Card> cards) async => ResultSets(
        cards: cards,
        removedCards: state.cards.toSet()..removeWhere(cards.contains),
      );

  void triggerHapticFeedbackMedium() => hapticFeedbackMediumUseCase.call(none);

  @override
  Future<DiscoveryState?> computeState() async => fold4(
        cardIndexConsumer,
        crudExplicitDocumentFeedbackConsumer,
        cardStream,
        _readerModeSettingsHandler,
      ).foldAll((
        cardIndex,
        explicitDocumentFeedback,
        documents,
        readerModeSettings,
        errorReport,
      ) async {
        _cardIndex ??= cardIndex;

        if (_cardIndex == null) return null;

        final requireDocuments = documents ?? const {};
        final cards = {...state.cards, ...requireDocuments.map(Card.document)};

        /// override card index to start from the first card in case of having
        /// an inline card as the first card in the feed
        ///
        if (_cardIndex == 1 &&
            cards.isNotEmpty &&
            cards.first.type != CardType.document) {
          _cardIndex = 0;
        }

        final sets = await maybeReduceCardCount(cards);
        final nextCardIndex = sets.nextCardIndex;

        if (errorReport.isNotEmpty) {
          logger.e('Something went wrong in $runtimeType: ${{
            'cardIndexConsumer': errorReport.of(cardIndexConsumer).toString(),
            'crudExplicitDocumentFeedbackConsumer':
                errorReport.of(crudExplicitDocumentFeedbackConsumer).toString(),
            'engineEvents': errorReport.of(cardStream).toString(),
            'readerModeSettingsHandler':
                errorReport.of(_readerModeSettingsHandler).toString(),
          }}');
        }

        if (nextCardIndex != null) _cardIndex = nextCardIndex;

        final hasIsFullScreenChanged = state.isFullScreen != _isFullScreen;
        final feedback =
            explicitDocumentFeedback?.mapOrNull(single: (v) => v.value);
        final hasExplicitDocumentFeedbackChanged =
            state.latestExplicitDocumentFeedback != feedback;
        final nextState = DiscoveryState(
          cards: sets.cards,
          isComplete: !isLoading,
          isFullScreen: _isFullScreen,
          didReachEnd: didReachEnd,
          cardIndex: _cardIndex!,
          latestExplicitDocumentFeedback: feedback,
          shouldUpdateNavBar:
              hasIsFullScreenChanged || hasExplicitDocumentFeedbackChanged,
          readerModeBackgroundColor:
              _isFullScreen ? readerModeSettings?.backgroundColor : null,
        );

        final uriList = sets.cards
            .where((it) => it.type == CardType.document)
            .map((it) => it.document.resource.url)
            .toSet();

        cardManagersCache.removeObsoleteCardManagers(sets.removedCards
            .where((it) => it.type == CardType.document)
            .where((it) => !uriList.contains(it.document.resource.url))
            .map((it) => it.document));

        // guard against same-state emission
        if (!nextState.equals(state)) return nextState;
      });

  DocumentViewMode _currentViewMode(DocumentId id) =>
      _documentCurrentViewMode[id] ?? DocumentViewMode.story;

  /// secondary observation action, check if we should implicitly like the [Document]
  @override
  void onObservation(DiscoveryCardMeasuredObservation observation) {
    super.onObservation(observation);

    var document = observation.document!;
    final isCardOpened = observation.viewType != DocumentViewMode.story;
    final isObservedLongEnough = observation.duration.inSeconds >=
        _kThresholdDurationSecondsImplicitLike;

    if (isCardOpened && isObservedLongEnough) {
      // lookup the same document in state, as it may have been updated with a new user reaction
      document = state.cards
          .map((it) => it.document)
          .cast<Document>()
          .firstWhere((it) => it.documentId == document.documentId,
              orElse: () => document);

      changeUserReaction(
        document: document,
        userReaction: UserReaction.positive,
        context: FeedbackContext.implicit,
        feedType: feedType,
      );
    }
  }

  void onChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      scheduleComputeState(() {});
    }
  }
}

class ResultSets {
  final int? nextCardIndex;
  final Set<Card> cards;
  final Set<Card> removedCards;

  const ResultSets({
    required this.cards,
    this.nextCardIndex,
    this.removedCards = const <Card>{},
  });
}
