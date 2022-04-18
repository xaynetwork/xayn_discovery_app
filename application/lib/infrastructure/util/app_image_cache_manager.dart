import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injectable/injectable.dart';

const Duration _kStalePeriod = Duration(days: 1);
const int _kMaxNrOfCacheObjects = 200;

@LazySingleton(as: ImageCacheManager)
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
