import 'package:xayn_architecture/concepts/use_case/handlers/fold.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_bloc_helper.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_stream.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_engine_results_use_case.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_state.dart';
import 'package:injectable/injectable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_state.dart';
import 'package:xayn_discovery_app/presentation/navigation/screen/controller.dart';

// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/domain/models/search_type.dart';

/// Manages the state for the active search screen.
///
/// It consumes events from the discovery engine and emits a state
/// which contains a list of discovery news items which should be displayed
/// in a list format by widgets.
@injectable
class ActiveSearchManager extends Cubit<ActiveSearchState>
    with UseCaseBlocHelper<ActiveSearchState> {
  ActiveSearchManager(
    this._screenController,
    this._discoveryEngineResultsUseCase,
  ) : super(ActiveSearchState.empty()) {
    _init();
  }

  final ScreenController _screenController;
  final DiscoveryEngineResultsUseCase _discoveryEngineResultsUseCase;
  late final UseCaseSink<DiscoveryEngineResultsParam, DiscoveryEngineState>
      _searchHandler;

  void handleSearch(String term) {
    _searchHandler(DiscoveryEngineResultsParam(
      searchTerm: term,
      searchTypes: const [SearchType.web],
    ));
  }

  void _init() {
    _searchHandler = pipe(_discoveryEngineResultsUseCase);
  }

  void onAccountClicked() => _screenController.openAccount(param: true);

  void onHomeClicked() => _screenController.openHome();

  @override
  Future<ActiveSearchState?> computeState() async =>
      fold(_searchHandler).foldAll((engineState, errorReport) {
        if (errorReport.isNotEmpty) {
          return state.copyWith(
            isInErrorState: true,
          );
        }

        if (engineState != null) {
          return state.copyWith(
            results: engineState.results,
            isLoading: engineState.isLoading,
            isComplete: engineState.isComplete,
            isInErrorState: false,
          );
        }
      });
}
