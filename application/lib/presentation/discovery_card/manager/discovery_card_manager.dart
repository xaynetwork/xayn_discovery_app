import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:xayn_architecture/concepts/use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/image_processing/image_palette_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/extract_elements_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/load_html_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/readability_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';

typedef UriHandler = void Function(Uri uri);

/// The state manager of a [DiscoveryCard] widget.
///
/// Currently has 2 goals:
/// - provide the html reader mode elements for the story-mode display
/// - provide the color palette of the card's background image
@injectable
class DiscoveryCardManager extends Cubit<DiscoveryCardState>
    with UseCaseBlocHelper<DiscoveryCardState> {
  final LoadHtmlUseCase _loadHtmlUseCase;
  final ReadabilityUseCase _readabilityUseCase;
  final ExtractElementsUseCase _extractElementsUseCase;
  final ImagePaletteUseCase _imagePaletteUseCase;

  late final UseCaseSink<Uri, Elements> _updateUri;
  late final UseCaseSink<Uri, PaletteGenerator> _updateImageUri;

  bool _isLoading = false;

  DiscoveryCardManager(
    this._loadHtmlUseCase,
    this._readabilityUseCase,
    this._extractElementsUseCase,
    this._imagePaletteUseCase,
  ) : super(DiscoveryCardState.initial()) {
    _init();
  }

  /// Update the uri which contains the news article
  void updateUri(Uri uri) => _updateUri(uri);

  /// Update the uri which contains the news article's background image
  void updateImageUri(Uri uri) => _updateImageUri(uri);

  Future<void> _init() async {
    /// html reader mode elements:
    ///
    /// - loads the source html
    ///   * emits a loading state while the source html is loading
    /// - transforms the loaded html into reader mode html
    /// - extracts lists of html elements from the html tree, to display in story mode
    _updateUri = pipe(_loadHtmlUseCase).transform(
      (out) => out
          .scheduleComputeState(
            condition: (it) => !it.isCompleted,
            whenTrue: (it) => _isLoading = true,
          )
          .map(_createReadabilityConfig)
          .followedBy(_readabilityUseCase)
          .followedBy(_extractElementsUseCase)
          .scheduleComputeState(
            condition: (it) => true,
            whenTrue: (it) => _isLoading = false,
            swallowEvent: false,
          ),
    );

    /// background image color palette:
    /// - invokes the palette use case and grabs the color palette
    _updateImageUri = pipe(_imagePaletteUseCase);
  }

  @override
  Future<DiscoveryCardState?> computeState() async =>
      fold2(_updateUri, _updateImageUri).foldAll((a, b, errorReport) {
        if (errorReport.isNotEmpty) {
          return DiscoveryCardState.error();
        }

        var nextState = state.copyWith(
          paletteGenerator: b,
          isComplete: !_isLoading,
        );

        if (a != null) {
          nextState = nextState.copyWith(
            result: a.processHtmlResult,
            paragraphs: a.paragraphs,
            images: a.images,
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
