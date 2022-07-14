import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/reset_ai_use_case.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/reset_ai/manager/resetting_ai_state.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager_mixin.dart';

@injectable
class ResettingAIManager extends Cubit<ResettingAIState>
    with
        UseCaseBlocHelper<ResettingAIState>,
        OverlayManagerMixin<ResettingAIState> {
  final ResetAIUseCase resetAIUseCase;

  ResettingAIManager(
    this.resetAIUseCase,
  ) : super(Loading());

  late final UseCaseValueStream<bool> _resetAIHandler =
      consume(resetAIUseCase, initialData: none);

  void resetAI() => resetAIUseCase.call(none);

  @override
  Future<ResettingAIState?> computeState() async =>
      fold(_resetAIHandler).foldAll(
        (
          resetAISucceeded,
          errorReport,
        ) {
          final error = errorReport.of(_resetAIHandler);
          final failed = error != null || resetAISucceeded == false;
          if (failed) {
            return ResetFailed();
          } else if (resetAISucceeded == true) {
            return ResetSucceeded();
          } else {
            return Loading();
          }
        },
      );
}
