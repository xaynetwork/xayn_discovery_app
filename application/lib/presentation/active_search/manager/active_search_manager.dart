import 'package:xayn_architecture/concepts/use_case/handlers/fold.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_bloc_helper.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_stream.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_engine_results_use_case.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_state.dart';
import 'package:injectable/injectable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_state.dart';

/// Manages the state for the active search screen.
///
/// It consumes events from the discovery engine and emits a state
/// which contains a list of discovery news items which should be displayed
/// in a list format by widgets.
@injectable
class ActiveSearchManager extends Cubit<ActiveSearchState>
    with UseCaseBlocHelper<ActiveSearchState> {
  ActiveSearchManager(
    this._discoveryEngineResultsUseCase,
  ) : super(ActiveSearchState.empty()) {
    _init();
  }

  final DiscoveryEngineResultsUseCase _discoveryEngineResultsUseCase;
  late final UseCaseValueStream<DiscoveryEngineState> _resultsObserver;

  void search(String term) => _discoveryEngineResultsUseCase.search(term);

  void _init() {
    _resultsObserver =
        consume(_discoveryEngineResultsUseCase, initialData: null);
  }

  @override
  Future<ActiveSearchState?> computeState() async =>
      fold(_resultsObserver).foldAll((a, errorReport) {
        if (errorReport.isNotEmpty) {
          return state.copyWith(
            isInErrorState: true,
          );
        }

        if (a != null) {
          return state.copyWith(
            results: a.results,
            isLoading: a.isLoading,
            isComplete: a.isComplete,
            isInErrorState: false,
          );
        }
      });
}
