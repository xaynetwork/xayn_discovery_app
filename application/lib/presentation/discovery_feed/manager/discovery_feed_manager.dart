import 'dart:math';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/on_failure.dart';
import 'package:xayn_architecture/concepts/use_case.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_engine_result_combiner_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_engine_results_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_state.dart';

/// These are random keywords, real keywords are to be provided by the
/// real discovery engine.
const List<String> randomKeywords = [
  'german',
  'french',
  'english',
  'american',
  'hollywood',
  'music',
  'broadway',
  'football',
  'tennis',
  'covid',
  'trump',
  'merkel',
  'cars',
  'sports',
  'market',
  'economy',
  'financial',
];

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
    _initGeneral();
  }

  final DiscoveryEngineResultsUseCase _discoveryEngineResultsUseCase;

  final Random rnd = Random();
  late String nextFakeKeyword;

  void loadMore() {
    _discoveryEngineResultsUseCase.search(nextFakeKeyword);
  }

  void _initGeneral() {
    nextFakeKeyword = randomKeywords[rnd.nextInt(randomKeywords.length)];
  }

  @override
  void initHandlers() {
    /// Consumes the discovery engine's results output,
    /// emits a managed list of max 15 results to subscribers.
    consume(_discoveryEngineResultsUseCase, initialData: nextFakeKeyword)
        .transform((out) => out.followedBy(
            DiscoveryEngineResultCombinerUseCase(() => state.results)))
        .fold(
          onSuccess: (it) => _extractFakeKeywordAndEmit(it),
          onFailure: HandleFailure((e, s) {
            //print('$e $s');
            return state.copyWith(
              isInErrorState: true,
            );
          }),
        );
  }

  DiscoveryFeedState _extractFakeKeywordAndEmit(ResultCombinerJob it) {
    nextFakeKeyword = _fakeNextKeywork(it.documents);

    return state.copyWith(
      results: it.documents,
      resultIndex:
          (state.resultIndex - it.removed).clamp(0, it.documents.length),
      isComplete: it.apiState.isComplete,
      isInErrorState: false,
    );
  }

  /// selects a random word from the combined set of [Result.description]s.
  String _fakeNextKeywork(List<Document> nextResults) {
    if (nextResults.isEmpty) {
      return randomKeywords[rnd.nextInt(randomKeywords.length)];
    }

    final words = nextResults
        .map((it) => it.webResource.snippet)
        .join(' ')
        .split(RegExp(r'[\s]+'))
        .where((it) => it.length >= 5)
        .toList(growable: false);

    if (words.isEmpty) {
      return randomKeywords[rnd.nextInt(randomKeywords.length)];
    }

    return words[rnd.nextInt(words.length)];
  }
}
