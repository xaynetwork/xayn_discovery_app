import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/log_engine_input_events_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/log_engine_output_events_use_case.dart';

import 'discovery_engine_report_state.dart';

@injectable
class DiscoveryEngineReportManager extends Cubit<DiscoveryEngineReportState>
    with UseCaseBlocHelper<DiscoveryEngineReportState> {
  late final LogEngineInputEventUseCase _engineInputUseCase;
  late final LogEngineOutputEventUseCase _engineOutputUseCase;

  late final UseCaseValueStream<String> _engineInputHandler =
      consume(_engineInputUseCase, initialData: none);
  late final UseCaseValueStream<String> _engineOutputHandler =
      consume(_engineOutputUseCase, initialData: none);

  DiscoveryEngineReportManager(
    this._engineOutputUseCase,
    this._engineInputUseCase,
  ) : super(
          DiscoveryEngineReportState.initial(),
        );

  @override
  Future<DiscoveryEngineReportState?> computeState() async =>
      fold2(_engineInputHandler, _engineOutputHandler).foldAll(
        (engineInput, engineOutput, _) {
          final input = engineInput != null
              ? [...state.inputEvents, engineInput]
              : state.inputEvents;
          final output = engineOutput != null
              ? [...state.outputEvents, engineOutput]
              : state.outputEvents;
          return DiscoveryEngineReportState(
            inputEvents: input,
            outputEvents: output,
          );
        },
      );
}
