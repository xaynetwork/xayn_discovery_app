import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/on_failure.dart';
import 'package:xayn_architecture/concepts/use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_engine_result_combiner_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_engine_results_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/random_keywords/random_keywords_use_case.dart';
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
    this._randomKeyWordsUseCase,
  ) : super(DiscoveryFeedState.empty());

  final DiscoveryEngineResultsUseCase _discoveryEngineResultsUseCase;
  final RandomKeyWordsUseCase _randomKeyWordsUseCase;

  String get _nextFakeKeyword => _randomKeyWordsUseCase.nextFakeKeyword;

  void loadMore() async {
    await _randomKeyWordsUseCase.call(state.results ?? []);
    _discoveryEngineResultsUseCase.search(_nextFakeKeyword);
  }

  @override
  void initHandlers() {
    /// Consumes the discovery engine's results output,
    /// emits a managed list of max 15 results to subscribers.
    consume(_discoveryEngineResultsUseCase, initialData: _nextFakeKeyword)
        .transform((out) => out.followedBy(
            DiscoveryEngineResultCombinerUseCase(() => state.results)))
        .fold(
          onSuccess: (it) => state.copyWith(
            results: it.documents,
            resultIndex:
                (state.resultIndex - it.removed).clamp(0, it.documents.length),
            isComplete: it.apiState.isComplete,
            isInErrorState: false,
          ),
          onFailure: HandleFailure((e, s) {
            //print('$e $s');
            return state.copyWith(
              isInErrorState: true,
            );
          }),
        );
  }
}
