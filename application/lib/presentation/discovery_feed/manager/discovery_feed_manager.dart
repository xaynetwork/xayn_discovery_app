import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_engine_result_combiner_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_engine_results_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_state.dart';

/// Manages the state for the main, or home discovery feed screen.
///
/// It consumes events from the discovery engine and emits a state
/// which contains a list of discovery news items which should be displayed
/// in a list format by widgets.
@injectable
class DiscoveryFeedManager extends Cubit<DiscoveryFeedState>
    with UseCaseBlocHelper<DiscoveryFeedState> {
  DiscoveryFeedManager(
    this._discoveryEngineResultsUseCase,
  ) : super(DiscoveryFeedState.empty()) {
    _initHandlers();
  }

  final DiscoveryEngineResultsUseCase _discoveryEngineResultsUseCase;

  late final UseCaseValueStream<ResultCombinerJob> _resultsObserver;

  void _initHandlers() {
    /// Consumes the discovery engine's results output,
    /// emits a managed list of max 15 results to subscribers.
    _resultsObserver = consume(_discoveryEngineResultsUseCase, initialData: 3)
        .transform((out) => out.followedBy(
            DiscoveryEngineResultCombinerUseCase(() => state.results)));
  }

  @override
  Future<DiscoveryFeedState?> computeState() async =>
      fold(_resultsObserver).foldAll((a, errorReport) {
        if (errorReport.isNotEmpty) {
          return state.copyWith(
            isInErrorState: true,
          );
        }

        if (a != null) {
          return state.copyWith(
            results: a.documents,
            resultIndex:
                (state.resultIndex - a.removed).clamp(0, a.documents.length),
            isComplete: a.apiState.isComplete,
            isInErrorState: false,
          );
        }
      });
}
