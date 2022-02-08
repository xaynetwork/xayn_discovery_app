import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/cache_manager/cache_manager_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/image_processing/direct_uri_use_case.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager_state.dart';

@injectable
class ImageManager extends Cubit<ImageManagerState>
    with UseCaseBlocHelper<ImageManagerState> {
  final DirectUriUseCase _directUriUseCase;

  late final UseCaseSink<Uri, CacheManagerEvent> _imageFromCacheHandler;

  Uri? _lastUri;

  ImageManager(
    this._directUriUseCase,
  ) : super(ImageManagerState.initial()) {
    _initHandlers();
  }

  void getImage(Uri uri) {
    if (uri == _lastUri) return;

    _lastUri = uri;
    _imageFromCacheHandler(uri);
  }

  @override
  Future<ImageManagerState?> computeState() async =>
      fold(_imageFromCacheHandler).foldAll((imageData, errorReport) {
        if (errorReport.isNotEmpty) {
          return ImageManagerState.error(uri: _lastUri!);
        }

        if (imageData != null) {
          final bytes = imageData.bytes;

          if (bytes != null) {
            return ImageManagerState.completed(
              uri: imageData.originalUri,
              bytes: bytes,
            );
          }

          return ImageManagerState.progress(
            uri: imageData.originalUri,
            progress: imageData.progress,
          );
        }
      });

  void _initHandlers() {
    _imageFromCacheHandler = pipe(_directUriUseCase);
  }
}
