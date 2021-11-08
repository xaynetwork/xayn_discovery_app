import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/on_failure.dart';
import 'package:xayn_architecture/concepts/use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/image_processing/image_palette_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/reader_mode.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';

typedef UriHandler = void Function(Uri uri);

@injectable
class DiscoveryCardManager extends Cubit<DiscoveryCardState>
    with UseCaseBlocHelper<DiscoveryCardState> {
  final LoadHtmlUseCase _loadHtmlUseCase;
  final ReadabilityUseCase _readabilityUseCase;
  final ExtractElementsUseCase _extractElementsUseCase;
  final ImagePaletteUseCase _imagePaletteUseCase;

  late final UriHandler _updateUri;
  late final UriHandler _updateImageUri;

  DiscoveryCardManager(
    this._loadHtmlUseCase,
    this._readabilityUseCase,
    this._extractElementsUseCase,
    this._imagePaletteUseCase,
  ) : super(DiscoveryCardState.initial()) {
    init();
  }

  void updateUri(Uri uri) => _updateUri(uri);

  void updateImageUri(Uri uri) => _updateImageUri(uri);

  Future<void> init() async {
    _updateUri = pipe(_loadHtmlUseCase)
        .transform(
          (out) => out
              .maybeResolveEarly(
                condition: (it) => !it.isCompleted,
                stateBuilder: (it) => state.copyWith(isComplete: false),
              )
              .map(_createReadabilityConfig)
              .followedBy(_readabilityUseCase)
              .followedBy(_extractElementsUseCase),
        )
        .fold(
          onSuccess: (it) => state.copyWith(
            result: it.processHtmlResult,
            paragraphs: it.paragraphs,
            images: it.images,
          ),
          onFailure: HandleFailure((e, st) {
            log('e: $e, st: $st');
            return DiscoveryCardState.error();
          }, matchers: {
            On<TimeoutException>((e, st) => DiscoveryCardState.error()),
            On<FormatException>((e, st) => DiscoveryCardState.error()),
          }),
        );

    _updateImageUri = pipe(_imagePaletteUseCase).fold(
      onSuccess: (it) => state.copyWith(paletteGenerator: it),
      onFailure: HandleFailure(
        (e, st) {
          log('e: $e, st: $st');
          return DiscoveryCardState.error();
        },
      ),
    );
  }

  ReadabilityConfig _createReadabilityConfig(Progress progress) =>
      ReadabilityConfig(
        uri: progress.uri,
        html: progress.html,
        disableJsonLd: true,
        classesToPreserve: const [],
      );
}
