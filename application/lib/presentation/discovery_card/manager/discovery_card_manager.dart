import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/extract_elements_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/heuristic_filter_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/load_html_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/readability_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

typedef UriHandler = void Function(Uri uri);

/// The state manager of a [DiscoveryCard] widget.
///
/// Currently has 2 goals:
/// - provide the html reader mode elements for the story-mode display
/// - provide the color palette of the card's background image
@injectable
class DiscoveryCardManager extends Cubit<DiscoveryCardState>
    with UseCaseBlocHelper<DiscoveryCardState> {
  final ConnectivityUriUseCase _connectivityUseCase;
  final LoadHtmlUseCase _loadHtmlUseCase;
  final ReadabilityUseCase _readabilityUseCase;
  final ExtractElementsUseCase _extractElementsUseCase;
  final HeuristicFilterUseCase _heuristicFilterUseCase;

  late final UseCaseSink<Uri, Elements> _updateUri;

  bool _isLoading = false;

  late bool _isInReaderMode;

  DiscoveryCardManager(
    this._connectivityUseCase,
    this._loadHtmlUseCase,
    this._readabilityUseCase,
    this._extractElementsUseCase,
    this._heuristicFilterUseCase,
  ) : super(DiscoveryCardState.initial()) {
    _init();
  }

  /// Update the uri which contains the news article
  void updateUri(Uri uri) => _updateUri(uri);

  void toggleReaderMode() {
    scheduleComputeState(() => _isInReaderMode = !_isInReaderMode);
  }

  Future<void> _init() async {
    _isInReaderMode = state.isInReaderMode;

    /// html reader mode elements:
    ///
    /// - loads the source html
    ///   * emits a loading state while the source html is loading
    /// - transforms the loaded html into reader mode html
    /// - extracts lists of html elements from the html tree, to display in story mode
    _updateUri = pipe(_connectivityUseCase).transform(
      (out) => out
          .distinct()
          .followedBy(_loadHtmlUseCase)
          .scheduleComputeState(
            consumeEvent: (it) => !it.isCompleted,
            run: (it) => _isLoading = !it.isCompleted,
          )
          .map(_createReadabilityConfig)
          .followedBy(_readabilityUseCase)
          .followedBy(_extractElementsUseCase)
          .followedBy(_heuristicFilterUseCase),
    );
  }

  @override
  Future<DiscoveryCardState?> computeState() async =>
      fold(_updateUri).foldAll((elements, errorReport) {
        if (errorReport.isNotEmpty) {
          logger.e(errorReport.of(_updateUri)!.error);

          return DiscoveryCardState.error();
        }

        var nextState = state.copyWith(
          isComplete: !_isLoading,
          isInReaderMode: _isInReaderMode,
        );

        if (elements != null) {
          nextState = nextState.copyWith(
            result: elements.processHtmlResult,
            paragraphs: elements.paragraphs,
          );
        }

        return nextState;
      });

  ReadabilityConfig _createReadabilityConfig(Progress progress) =>
      ReadabilityConfig(
        uri: progress.uri,
        html: progress.html,
        disableJsonLd: true,
        classesToPreserve: const [],
      );
}
