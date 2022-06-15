import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/engine_events_use_case.dart';
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
        ErrorHandlingManagerMixin<DeepSearchState>
    implements DeepSearchScreenManagerNavActions {
  final EngineEventsUseCase _engineEventsUseCase;
  final DeepSearchScreenManagerNavActions _navActions;

  DeepSearchScreenManager(
    @factoryParam DocumentId? documentId,
    this._engineEventsUseCase,
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
        if (event is DeepSearchRequestSucceeded) {
          return DeepSearchState.success(event.items.toSet());
        } else if (event is DeepSearchRequestSucceeded) {
          return const DeepSearchState.failure();
        }
      });

  @override
  void onBackNavPressed() => _navActions.onBackNavPressed();
}
