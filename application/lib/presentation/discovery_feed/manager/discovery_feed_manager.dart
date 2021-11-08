import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_engine_result_combiner_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_engine_results_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_state.dart';

@injectable
class DiscoveryFeedManager extends Cubit<DiscoveryFeedState>
    with UseCaseBlocHelper<DiscoveryFeedState> {
  DiscoveryFeedManager(
    this._discoveryEngineResultsUseCase,
  ) : super(DiscoveryFeedState.empty());

  final DiscoveryEngineResultsUseCase _discoveryEngineResultsUseCase;

  @override
  void initHandlers() {
    consume(_discoveryEngineResultsUseCase, initialData: 3)
        .transform((out) => out.followedBy(
            DiscoveryEngineResultCombinerUseCase(() => state.results)))
        .fold(
          onSuccess: (it) => state.copyWith(
            results: it.documents,
            resultIndex:
                (state.resultIndex - it.removed).clamp(0, it.documents.length),
            isComplete: it.apiState.isComplete,
            isInErrorState: false,
          ), // todo: instead of null, a loading state
          onFailure: HandleFailure((e, s) {
            //print('$e $s');
            return state.copyWith(
              isInErrorState: true,
            );
          }),
        );
  }
}
