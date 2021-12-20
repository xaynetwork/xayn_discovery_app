import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/cache_manager/cache_manager_event.dart';
import 'package:xayn_discovery_app/domain/model/cache_manager/fetcher_params.dart';

const Duration _kStalePeriod = Duration(days: 1);
const int _kMaxNrOfCacheObjects = 200;

@injectable
class CacheManagerUseCase extends UseCase<FetcherParams, CacheManagerEvent> {
  final ImageCacheManager _cacheManager;

  @visibleForTesting
  CacheManagerUseCase(this._cacheManager);

  @factoryMethod
  CacheManagerUseCase.withAppImageCacheManager()
      : _cacheManager = AppImageCacheManager();

  @override
  Stream<CacheManagerEvent> transaction(FetcherParams param) async* {
    yield* _cacheManager
        .getImageFile(param.uri.toString(), withProgress: true)
        .asyncMap((it) async {
      if (it is FileInfo) {
        return CacheManagerEvent.completed(
            param.uri, await it.file.readAsBytes());
      } else if (it is DownloadProgress) {
        return CacheManagerEvent.progress(param.uri, it.progress ?? .0);
      }

      throw CacheManagerError();
    });
  }
}

class AppImageCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'libAppCachedImageData';

  static final AppImageCacheManager _instance = AppImageCacheManager._();
  factory AppImageCacheManager() {
    return _instance;
  }

  AppImageCacheManager._()
      : super(Config(
          key,
          stalePeriod: _kStalePeriod,
          maxNrOfCacheObjects: _kMaxNrOfCacheObjects,
        ));
}
