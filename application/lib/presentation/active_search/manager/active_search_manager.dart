import 'package:xayn_architecture/concepts/on_failure.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_bloc_helper.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_engine_results_use_case.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_state.dart';
import 'package:injectable/injectable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

@injectable
class ActiveSearchManager extends Cubit<ActiveSearchState>
    with UseCaseBlocHelper<ActiveSearchState> {
  ActiveSearchManager(
    this._discoveryEngineResultsUseCase,
  ) : super(ActiveSearchState.empty());

  final DiscoveryEngineResultsUseCase _discoveryEngineResultsUseCase;

  void search(String term) => _discoveryEngineResultsUseCase.search(term);

  @override
  void initHandlers() {
    consume(_discoveryEngineResultsUseCase, initialData: null).fold(
      onSuccess: (it) => state.copyWith(
        results: it.results,
        isComplete: it.isComplete,
        isLoading: it.isLoading,
        isInErrorState: false,
      ),
      onFailure: HandleFailure((e, s) {
        return state.copyWith(
          isInErrorState: true,
        );
      }),
    );
  }
}
