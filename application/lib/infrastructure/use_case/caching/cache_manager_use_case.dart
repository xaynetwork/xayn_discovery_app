import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';

const Duration kStalePeriod = Duration(days: 1);
const int kMaxNrOfCacheObjects = 200;

@injectable
class CacheManagerUseCase extends UseCase<Uri, CacheManagerEvent> {
  final ImageCacheManager _cacheManager;

  @visibleForTesting
  CacheManagerUseCase(this._cacheManager);

  @factoryMethod
  CacheManagerUseCase.withAppImageCacheManager()
      : _cacheManager = AppImageCacheManager();

  @override
  Stream<CacheManagerEvent> transaction(Uri param) async* {
    yield* _cacheManager.getImageFile(param.toString()).asyncMap((it) async {
      if (it is FileInfo) {
        return CacheManagerEvent.completed(param, await it.file.readAsBytes());
      } else if (it is DownloadProgress) {
        return CacheManagerEvent.progress(param, it.progress ?? .0);
      }

      throw CacheManagerError();
    });
  }
}

class CacheManagerEvent {
  final Uri originalUri;
  final double progress;
  final Uint8List? bytes;

  const CacheManagerEvent({
    required this.originalUri,
    required this.progress,
    required this.bytes,
  });

  const CacheManagerEvent.progress(this.originalUri, this.progress)
      : bytes = null;

  const CacheManagerEvent.completed(this.originalUri, this.bytes)
      : progress = 1.0;
}

class CacheManagerError extends Error {}

class AppImageCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'libAppCachedImageData';

  static final AppImageCacheManager _instance = AppImageCacheManager._();
  factory AppImageCacheManager() {
    return _instance;
  }

  AppImageCacheManager._()
      : super(Config(
          key,
          stalePeriod: kStalePeriod,
          maxNrOfCacheObjects: kMaxNrOfCacheObjects,
        ));
}
