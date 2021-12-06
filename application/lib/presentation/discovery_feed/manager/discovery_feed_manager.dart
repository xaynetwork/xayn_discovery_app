import 'dart:convert';

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
      'url': it.document.webResource.url,
      'view type': it.viewType,
      'time spent': '${it.duration.inSeconds} seconds',
    }.toString(),
  );

  late final UseCaseSink<List<Document>, DiscoveryEngineState> _searchHandler;
  late final UseCaseValueStream<DiscoveryFeedAxis> _discoveryFeedAxisHandler;
  late final UseCaseSink<DiscoveryCardObservation, bool>
      _discoveryCardObservationHandler;

  Document? _observedDocument;

  void handleIndexChanged(int index) {
    final document = _observedDocument = state.results?[index];

    if (document != null) {
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
      _discoveryCardObservationHandler(
        DiscoveryCardObservation(
          document: document,
          viewType: viewType,
        ),
      );
    }
  }

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
          .followedBy(_discoveryEngineResultsUseCase)
          .scheduleComputeState(
            consumeEvent: (it) => it.isLoading || it.results.isEmpty,
            run: (it) {
              if (!it.isLoading && it.results.isEmpty) {
                handleLoadMore();
              }
            },
          )
          .scan(
            (DiscoveryEngineState accumulated, value, index) =>
                DiscoveryEngineState(
                    isComplete: value.isComplete,
                    results: [...accumulated.results, ...value.results]),
            const DiscoveryEngineState.initial(),
          ),
    );

    _searchHandler.call(const <Document>[]);

    _discoveryFeedAxisHandler =
        consume(_listenDiscoveryFeedAxisUseCase, initialData: none);

    _discoveryCardObservationHandler =
        pipe(_discoveryCardObservationUseCase).transform(
      (out) => out
          .pairwise()
          .followedBy(_discoveryCardMeasuredObservationUseCase)
          .followedBy(_measuredObservationLogger)
          .bufferCount(kBufferCount)
          .map((list) => list.fold(
              Duration.zero,
              (Duration previousValue, element) =>
                  previousValue + element.duration))
          .map((timeSpent) =>
              timeSpent > kResolveCardAsSkippedDuration * kBufferCount),
    );
  }

  @override
  Future<DiscoveryFeedState?> computeState() async => fold3(
        _searchHandler,
        _discoveryFeedAxisHandler,
        _discoveryCardObservationHandler,
      ).foldAll((engineState, axis, didDismissAll, errorReport) {
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
            );
          }
        }
      });
}
