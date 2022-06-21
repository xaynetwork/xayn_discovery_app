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

  /// Trigger this handler whenever the primary card changes.
  /// The [index] correlates with the index of the current primary card.
  void handleIndexChanged(int index) async {
    if (state is! SearchSuccessState) return;

    final currentState = state as SearchSuccessState;
    if (index >= currentState.results.length) return;

    scheduleComputeState(() {
      _cardIndex = index;
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
}
