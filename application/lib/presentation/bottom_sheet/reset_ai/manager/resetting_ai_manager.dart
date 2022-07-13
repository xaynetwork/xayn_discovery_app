import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/reset_ai_use_case.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/reset_ai/manager/resetting_ai_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager_mixin.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class ResettingAIManager extends Cubit<ResettingAIState>
    with
        UseCaseBlocHelper<ResettingAIState>,
        OverlayManagerMixin<ResettingAIState> {
  final ResetAIUseCase resetAIUseCase;
  final DiscoveryFeedManager discoveryFeedManager;

  ResettingAIManager(
    this.resetAIUseCase,
    this.discoveryFeedManager,
  ) : super(Loading());

  late final _resetAIHandler = consume(resetAIUseCase, initialData: none);

  void resetAI() => resetAIUseCase.call(none);

  @override
  Future<ResettingAIState?> computeState() async =>
      fold(_resetAIHandler).foldAll(
        (engineEvent, errorReport) {
          final error = errorReport.of(_resetAIHandler);
          if (error != null) {
            return ResetFailed();
          }

          if (engineEvent is EngineExceptionRaised) {
            return ResetFailed();
          }

          if (engineEvent.toString() == 'EngineEvent.resetAiSucceeded()') {
            discoveryFeedManager.onResetAISucceeded();
            return ResetSucceeded();
          }
          return state;
        },
      );
}
