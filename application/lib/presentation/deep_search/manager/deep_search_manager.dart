// ignore_for_file: avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/engine_events_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/check_valid_document_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/observe_document_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/request_deep_search_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/singleton_subscription_observer.dart';
import 'package:xayn_discovery_app/presentation/error/mixin/error_handling_manager_mixin.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

import 'deep_search_state.dart';

abstract class DeepSearchScreenManagerNavActions {
  void onBackNavPressed();
}

@injectable
class DeepSearchScreenManager extends Cubit<DeepSearchState>
    with
        UseCaseBlocHelper<DeepSearchState>,
        SingletonSubscriptionObserver<DeepSearchState>,
        ObserveDocumentMixin<DeepSearchState>,
        RequestDeepSearchMixin<DeepSearchState>,
        OverlayManagerMixin<DeepSearchState>,
        CheckValidDocumentMixin<DeepSearchState>,
        ErrorHandlingManagerMixin<DeepSearchState>
    implements DeepSearchScreenManagerNavActions {
  final HapticFeedbackMediumUseCase _hapticFeedbackMediumUseCase;
  final EngineEventsUseCase _engineEventsUseCase;
  final DeepSearchScreenManagerNavActions _navActions;

  /// A weak-reference map which tracks the current [DocumentViewMode] of documents.
  final _documentCurrentViewMode = Expando<DocumentViewMode>();
  Document? _observedDocument;
  int? _cardIndex;
  bool _isFullScreen = false;

  int get cardIndex => _cardIndex ?? 0;
  bool get isFullScreen => _isFullScreen;

  DeepSearchScreenManager(
    @factoryParam DocumentId? documentId,
    this._engineEventsUseCase,
    this._hapticFeedbackMediumUseCase,
    this._navActions,
  ) : super(const DeepSearchState.init()) {
    if (documentId != null) {
      requestDeepSearch(documentId);
      emit(const DeepSearchState.loading());
    } else {
      emit(const DeepSearchState.failure());
    }
  }

  late final UseCaseValueStream<EngineEvent> engineEvents = consume(
    _engineEventsUseCase,
    initialData: none,
  );

  @override
  Future<DeepSearchState?> computeState() async =>
      fold(engineEvents).foldAll((event, errorReport) async {
        print('---- computeState ----');
        print('---- event ----');
        print(event);
        print('---- event ----\n');
        if (event is DeepSearchRequestSucceeded) {
          return DeepSearchState.success(event.items.toSet());
        } else if (event is DeepSearchRequestFailed) {
          return const DeepSearchState.failure();
          // } else if (event is EngineExceptionRaised) {
          //   return const DeepSearchState.failure();
        } else {
          return state;
        }
      });

  @override
  void onBackNavPressed() => _navActions.onBackNavPressed();

  DocumentViewMode _currentViewMode(DocumentId id) =>
      _documentCurrentViewMode[id] ?? DocumentViewMode.story;

  /// Trigger this handler whenever the primary card changes.
  /// The [index] correlates with the index of the current primary card.
  void handleIndexChanged(int index) async {
    if (state is! SearchSuccessState) return;

    final currentState = state as SearchSuccessState;
    if (index >= currentState.results.length) return;

    final nextDocument = currentState.results.elementAt(index);

    observeDocument(
      document: nextDocument,
      mode: _currentViewMode(nextDocument.documentId),
    );

    scheduleComputeState(() {
      _cardIndex = index;
      _observedDocument = nextDocument;
    });
  }

  void handleNavigateOutOfCard(Document document) {
    scheduleComputeState(() => _isFullScreen = false);
  }

  void handleNavigateIntoCard(Document document) {
    scheduleComputeState(() => _isFullScreen = true);
  }

  void maybeNavigateIntoCard(Document document) =>
      checkIfDocumentNotProcessable(
        document,
        onValid: () => handleNavigateIntoCard(document),
      );

  void triggerHapticFeedbackMedium() => _hapticFeedbackMediumUseCase.call(none);

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

  void resetObservedDocument() => _observedDocument = null;

  @override
  bool isDocumentCurrentlyDisplayed(Document document) =>
      state is SearchSuccessState &&
      (state as SearchSuccessState)
          .results
          .map((it) => it.documentId)
          .contains(document.documentId);
}
