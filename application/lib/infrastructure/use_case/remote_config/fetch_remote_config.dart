import 'package:dart_remote_config/dart_remote_config.dart';
import 'package:dart_remote_config/fetcher/cache_strategy.dart';
import 'package:dart_remote_config/model/dart_remote_config_state.dart';
import 'package:dart_remote_config/repository/remote_config_repository.dart';
import 'package:flutter/services.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

class S3Fetcher extends S3RemoteConfigFetcher {
  S3Fetcher(RemoteConfigRepository repo, LoadFallbackRemoteConfig fallback)
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
            cacheStrategy: CacheOnlyUpdateUnawaited(repo, fallback));
}

Future<DartRemoteConfigState> fetchRemoteConfig() {
  final repo = HiveRemoteConfigRepository();
  return DartRemoteConfig(
      fetcher: S3Fetcher(repo,
          () => rootBundle.loadString("assets/default_remote_config.yaml")),
      versionProvider: () => EnvironmentHelper.kGitTag).create();
}
