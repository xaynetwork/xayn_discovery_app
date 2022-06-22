// ignore_for_file: avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/engine_events_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/check_valid_document_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/request_deep_search_mixin.dart';
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
        RequestDeepSearchMixin<DeepSearchState>,
        OverlayManagerMixin<DeepSearchState>,
        CheckValidDocumentMixin<DeepSearchState>,
        ErrorHandlingManagerMixin<DeepSearchState>
    implements DeepSearchScreenManagerNavActions {
  final HapticFeedbackMediumUseCase _hapticFeedbackMediumUseCase;
  final EngineEventsUseCase _engineEventsUseCase;
  final DeepSearchScreenManagerNavActions _navActions;

  int? _cardIndex;
  int get cardIndex => _cardIndex ?? 0;
  bool get isFullScreen => state is DocumentViewState;

  DeepSearchScreenManager(
    @factoryParam DocumentId? documentId,
    this._engineEventsUseCase,
    this._hapticFeedbackMediumUseCase,
    this._navActions,
  ) : super(const InitState()) {
    final currentState = state;
    final isInit = currentState is InitState;
    if (isInit && documentId != null) {
      emit(currentState.requestDeepSearch());
      // TODO: this should be a side effect of state transition
      requestDeepSearch(documentId);
    } else {
      emit(currentState.reportError());
    }
  }

  late final UseCaseValueStream<EngineEvent> engineEvents = consume(
    _engineEventsUseCase,
    initialData: none,
  );

  @override
  Future<DeepSearchState?> computeState() async =>
      fold(engineEvents).foldAll((event, errorReport) async {
        final currentState = state;

        final isLoading = currentState is LoadingState;
        final isSuccessful = isLoading && event is DeepSearchRequestSucceeded;
        final isFailure = isLoading && event is DeepSearchRequestFailed;

        if (isSuccessful) {
          return currentState.requestSucceeded(event.items.toSet());
        } else if (isFailure) {
          return currentState.requestFailed();
        } else {
          return state;
        }
      });

  @override
  void onBackNavPressed() => _navActions.onBackNavPressed();

  /// Trigger this handler whenever the primary card changes.
  /// The [index] correlates with the index of the current primary card.
  void handleIndexChanged(int index) async {
    final currentState = state;

    if (currentState is! SearchSuccessState) return;
    if (index >= currentState.results.length) return;

    scheduleComputeState(() {
      _cardIndex = index;
    });
  }

  void handleNavigateOutOfCard(Document document) {
    final currentState = state;

    if (currentState is DocumentViewState) {
      emit(currentState.goBack());
    }
  }

  void handleNavigateIntoCard(Document document) {
    final currentState = state;

    if (currentState is SearchSuccessState) {
      emit(currentState.openDocument(document));
    }
  }

  void maybeNavigateIntoCard(Document document) =>
      checkIfDocumentNotProcessable(
        document,
        onValid: () => handleNavigateIntoCard(document),
      );

  void triggerHapticFeedbackMedium() => _hapticFeedbackMediumUseCase.call(none);
}
