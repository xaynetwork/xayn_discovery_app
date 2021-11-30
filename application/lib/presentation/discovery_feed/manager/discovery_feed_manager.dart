import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/document.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_scroll_direction.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_engine_results_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/listen_discovery_feed_scroll_direction_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/random_keywords/random_keywords_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_state.dart';

// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/domain/models/search_type.dart';

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
    this._listenDiscoveryFeedScrollDirectionUseCase,
  ) : super(DiscoveryFeedState.empty()) {
    _initHandlers();
  }

  final DiscoveryEngineResultsUseCase _discoveryEngineResultsUseCase;
  final RandomKeyWordsUseCase _randomKeyWordsUseCase;
  final ListenDiscoveryFeedScrollDirectionUseCase
      _listenDiscoveryFeedScrollDirectionUseCase;

  late final UseCaseSink<List<Document>, DiscoveryEngineState> _searchHandler;
  late final UseCaseValueStream<DiscoveryFeedScrollDirection>
      _discoveryFeedScrollDirectionHandler;

  void handleLoadMore() async {
    _searchHandler(state.results ?? const <Document>[]);
  }

  void _initHandlers() {
    /// Consumes the discovery engine's results output,
    /// emits a managed list of max 15 results to subscribers.
    _searchHandler = pipe(_randomKeyWordsUseCase).transform(
      (out) => out
          .map(
            (it) => DiscoveryEngineResultsParam(
              searchTerm: it,
              searchTypes: const [SearchType.web],
            ),
          )
          .followedBy(_discoveryEngineResultsUseCase),
    );

    _searchHandler.call(const <Document>[]);

    _discoveryFeedScrollDirectionHandler =
        consume(_listenDiscoveryFeedScrollDirectionUseCase, initialData: none);
  }

  @override
  Future<DiscoveryFeedState?> computeState() async =>
      fold2(_searchHandler, _discoveryFeedScrollDirectionHandler)
          .foldAll((engineState, scrollDirection, errorReport) {
        if (errorReport.isNotEmpty) {
          return state.copyWith(
            isInErrorState: true,
          );
        }

        if (engineState != null) {
          if (engineState.results.isNotEmpty) {
            return state.copyWith(
              results: [
                ...state.results ?? const <Document>[],
                ...engineState.results
              ],
              isComplete: engineState.isComplete,
              isInErrorState: false,
              scrollDirection:
                  scrollDirection ?? DiscoveryFeedScrollDirection.vertical,
            );
          }

          if (engineState.isComplete && engineState.results.isEmpty) {
            handleLoadMore();
          }
        }
      });
}
