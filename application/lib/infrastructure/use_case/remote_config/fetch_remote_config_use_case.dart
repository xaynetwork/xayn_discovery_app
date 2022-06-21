import 'package:dart_remote_config/dart_remote_config.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

@Injectable(as: RemoteConfigFetcher)
class S3Fetcher extends S3RemoteConfigFetcher {
  S3Fetcher()
      : super(
          bucketName: 'remote_configs_repo',
          s3Factory: defaultS3Factory(
            secretKey: Env.rconfigSecretKey,
            accessKey: Env.rconfigAccessKey,
            endpointUrl: Env.rconfigEndpointUrl,
            s3Region: Env.rconfigRegion,
          ),
          nameBuilder: defaultNameBuilder(
            appId: EnvironmentHelper.kAppId,
            flavor: EnvironmentHelper.kFlavor,
          ),
        );
}

@lazySingleton
class FetchRemoteConfigUseCase extends UseCase<None, RemoteConfigs?> {
  FetchRemoteConfigUseCase(this._fetcher);

  final RemoteConfigFetcher _fetcher;

  /// TODO use the last-modified field and also cache the config
  RemoteConfigs? _remoteConfigs;

  @override
  Stream<RemoteConfigs?> transaction(None param) async* {
    if (_remoteConfigs != null) {
      yield _remoteConfigs;
      return;
    }

    final res = await _fetcher.fetch();
    res.map(success: (s) {
      _remoteConfigs = s.remoteConfigs;
    }, failure: (f) {
      logger.e(f.toString());
    });

    yield _remoteConfigs;
  }
}
