import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/caching/cache_manager_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/image_processing/proxy_uri_use_case.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager_state.dart';

@injectable
class ImageManager extends Cubit<ImageManagerState>
    with UseCaseBlocHelper<ImageManagerState> {
  final ProxyUriUseCase _proxyUriUseCase;
  final CacheManagerUseCase _cacheManagerUseCase;

  late final UseCaseSink<FetcherParams, CacheManagerEvent>
      _imageFromCacheHandler;

  Uri? _lastUri;

  ImageManager(this._proxyUriUseCase, this._cacheManagerUseCase)
      : super(ImageManagerState.initial()) {
    _initHandlers();
  }

  void getImage(
    Uri uri, {
    int? width,
    int? height,
    BoxFit? fit,
  }) {
    String? fitAsString;

    switch (fit) {
      case BoxFit.cover:
        fitAsString = 'cover';
        break;
      case BoxFit.fill:
        fitAsString = 'fill';
        break;
      case BoxFit.contain:
        fitAsString = 'contain';
        break;
      default:
        fitAsString = null;
    }

    _lastUri = uri;
    _imageFromCacheHandler(FetcherParams(
      uri: uri,
      width: width,
      height: height,
      fit: fitAsString,
    ));
  }

  @override
  Future<ImageManagerState?> computeState() async =>
      fold(_imageFromCacheHandler).foldAll((imageData, errorReport) {
        if (errorReport.isNotEmpty) {
          return ImageManagerState.error(uri: _lastUri!);
        }

        if (imageData != null) {
          if (imageData.bytes != null) {
            return ImageManagerState.completed(
              uri: imageData.originalUri,
              bytes: imageData.bytes!,
            );
          }

          return ImageManagerState.progress(
            uri: imageData.originalUri,
            progress: imageData.progress,
          );
        }
      });

  void _initHandlers() {
    _imageFromCacheHandler = pipe(_proxyUriUseCase)
        .transform((out) => out.followedBy(_cacheManagerUseCase));
  }
}
