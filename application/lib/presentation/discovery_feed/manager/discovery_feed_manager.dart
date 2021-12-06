import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/document.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/log_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_card_observation_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_engine_results_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/listen_discovery_feed_axis_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/random_keywords/random_keywords_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_state.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/domain/models/search_type.dart';

const int kBufferCount = 4;
const Duration kResolveCardAsSkippedDuration = Duration(seconds: 3);

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
    this._listenDiscoveryFeedAxisUseCase,
    this._discoveryCardObservationUseCase,
    this._discoveryCardMeasuredObservationUseCase,
  ) : super(DiscoveryFeedState.empty()) {
    _initHandlers();
  }

  final DiscoveryEngineResultsUseCase _discoveryEngineResultsUseCase;
  final RandomKeyWordsUseCase _randomKeyWordsUseCase;
  final ListenDiscoveryFeedAxisUseCase _listenDiscoveryFeedAxisUseCase;
  final DiscoveryCardObservationUseCase _discoveryCardObservationUseCase;
  final DiscoveryCardMeasuredObservationUseCase
      _discoveryCardMeasuredObservationUseCase;

  final LogUseCase<DiscoveryCardMeasuredObservation>
      _measuredObservationLogger = LogUseCase(
    (it) => {
      'todo': 'submit this data to the discovery engine',
      'url': it.document?.webResource.url,
      'view type': it.viewType,
      'time spent': '${it.duration.inSeconds} seconds',
    }.toString(),
    when: (it) => it.document != null && it.duration.inSeconds > 0,
    logger: logger,
  );
  final LogUseCase<int> _suggestTopicsAtIndexLogger = LogUseCase(
    (it) =>
        'the last $kBufferCount cards were skipped fast!\nshow a topics card after card index $it',
    logger: logger,
  );

  late final UseCaseSink<List<Document>, DiscoveryEngineState> _searchHandler;
  late final UseCaseValueStream<DiscoveryFeedAxis> _discoveryFeedAxisHandler;
  late final UseCaseSink<DiscoveryCardObservation, int>
      _discoveryCardObservationHandler;

  Document? _observedDocument;
  DocumentViewType? _observedViewType;

  void handleIndexChanged(int index) {
    final document = _observedDocument = state.results?[index];

    if (document != null) {
      _observedViewType = DocumentViewType.story;

      _discoveryCardObservationHandler(
        DiscoveryCardObservation(
          document: document,
          viewType: DocumentViewType.story,
        ),
      );
    }
  }

  void handleViewType(Document document, DocumentViewType viewType) {
    if (document == _observedDocument) {
      _observedViewType = viewType;

      _discoveryCardObservationHandler(
        DiscoveryCardObservation(
          document: document,
          viewType: viewType,
        ),
      );
    }
  }

  void handleActivityStatus(bool isAppInForeground) {
    final observation = isAppInForeground
        ? DiscoveryCardObservation(
            document: _observedDocument,
            viewType: _observedViewType,
          )
        : const DiscoveryCardObservation.none();

    _discoveryCardObservationHandler(observation);
  }

  void handleLoadMore() async {
    _searchHandler(state.results ?? const <Document>[]);
  }

  void _initHandlers() {
    /// accumulates all past results with the latest results.
    /// this way, `_searchHandler` will always emit a `List` containing
    /// all results of the feed, making `computeState` deterministic.
    combineAllResults(DiscoveryEngineState accumulatedState, value, index) =>
        DiscoveryEngineState(
            isComplete: value.isComplete,
            results: [...accumulatedState.results, ...value.results]);

    /// this is invoked when the discovery engine returns with results from
    /// the last submitted query.
    /// in some cases, no results are returned, and then we need to trigger
    /// the discovery engine again with a different query.
    /// todo: this all becomes obsolete once we have the real discovery engine
    maybeLoadMore(DiscoveryEngineState state) {
      if (!state.isLoading && state.results.isEmpty) {
        // if not loading, and the current batch has 0 results,
        // then we need to fire a new query.
        // this repeats within this chain, until new results
        // are indeed available, so that the user can finally scroll
        // to the next card(s).
        handleLoadMore();
      }
    }

    /// Invokes the fake discovery engine with a random search query.
    /// Should the random keyword come up with 0 results,
    /// then `maybeLoadMore` will attempt another call with a newly
    /// generated random keyword, until we finally do get results.
    ///
    /// `scan` is part of rxdart, it basically accumulates all results
    /// from all past events, including the newest one, into a single
    /// combined result set.
    ///
    /// This makes `computeState` run deterministic, see also `combineAllResults`.
    /// (see [scan](https://rxmarbles.com/#scan))
    ///
    /// `deterministic` implies that `computeState` can be run _at any given time_,
    /// and just needs to take the latest event's results as the next results,
    /// it avoids having to do inner state-management inside this manager.
    _searchHandler = pipe(_randomKeyWordsUseCase).transform(
      (out) => out
          .map(
            (it) => DiscoveryEngineResultsParam(
              searchTerm: it,
              searchTypes: const [SearchType.web],
            ),
          )
          .followedBy(_discoveryEngineResultsUseCase)
          .doOnData(maybeLoadMore)
          .scan(
            combineAllResults,
            const DiscoveryEngineState.initial(),
          ),
    );

    // trigger an initial random keyword to show the initial results.
    _searchHandler.call(const <Document>[]);

    _discoveryFeedAxisHandler =
        consume(_listenDiscoveryFeedAxisUseCase, initialData: none);

    /// This flow observes individual cards,
    /// - first, it adds a timestamp when an observation occurs via `_discoveryCardObservationUseCase`
    /// - then it uses `pairWise` so that it bundles the previous and the current events, see [pairwise](https://rxmarbles.com/#pairwise)
    /// - then, it logs the measured observation using the logger, todo: this will be submitted to the real discovery engine
    /// - then, it buffers the last `kBufferCount` observations, see [buffer](https://rxmarbles.com/#buffer)
    /// - when the buffer reaches its count, it then folds its observations into a single, accumulated time spent over all observations.
    /// - should this total duration not reach a certain value, then we consider the buffered batch as 'user-skipped cards'
    ///
    /// So, if finally we get `true` from this flow, then the buffered cards were
    /// not very interesting to the user, as they were skipped fast enough one-by-one.
    ///
    /// In that case, we can decide to show an in-between card where the user can
    /// maybe enter a custom keyword, or select a topic from a predefined list.
    ///
    /// To know in a deterministic way which card index the user was at when
    /// the dismiss flow triggered, we map it to the last known document index.
    _discoveryCardObservationHandler =
        pipe(_discoveryCardObservationUseCase).transform(
      (out) => out
          .pairwise() // combine last card and current card
          .followedBy(_discoveryCardMeasuredObservationUseCase)
          .followedBy(_measuredObservationLogger)
          .bufferCount(
              kBufferCount) // observe the last kBufferCount card durations in one batch
          .map((list) => list.fold(
              Duration.zero,
              (Duration previousValue, element) =>
                  previousValue +
                  element
                      .duration)) // accumulate into a total duration over all cards in the batch
          .map((timeSpent) =>
              timeSpent <=
              kResolveCardAsSkippedDuration *
                  kBufferCount) // resolve if swiped fast enough to mark the batch as dismissed
          .where((didDismissLastCards) =>
              didDismissLastCards) // we only care for dismissed batches
          .map((_) => state.results!
              .indexOf(_observedDocument!)) // resolve the current card index
          .scan((int max, value, index) => value > max ? value : max,
              0) // keep only the maximum index
          .followedBy(_suggestTopicsAtIndexLogger),
    );
  }

  @override
  Future<DiscoveryFeedState?> computeState() async => fold3(
        _searchHandler,
        _discoveryFeedAxisHandler,
        _discoveryCardObservationHandler,
      ).foldAll((
        engineState,
        axis,
        suggestTopicsAtIndex,
        errorReport,
      ) {
        if (errorReport.isNotEmpty) {
          return state.copyWith(
            isInErrorState: true,
          );
        }

        if (engineState != null) {
          if (engineState.results.isNotEmpty) {
            return state.copyWith(
              results: engineState.results,
              isComplete: engineState.isComplete,
              isInErrorState: false,
              axis: axis ?? DiscoveryFeedAxis.vertical,
              suggestTopicsAtIndex: suggestTopicsAtIndex,
            );
          }
        }
      });
}
