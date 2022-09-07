import 'package:dart_remote_config/dart_remote_config.dart';
import 'package:dart_remote_config/model/dart_remote_config_state.dart';
import 'package:dart_remote_config/repository/remote_config_repository.dart';
import 'package:flutter/foundation.dart';
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

Future<DartRemoteConfigState> fetchRemoteConfig() async {
  final repo = HiveRemoteConfigRepository();

  if (kDebugMode) {
    final secondRemoteConfig =
        await tryLoadingAsset('assets/remote_config/second.yaml');

    if (secondRemoteConfig != null) {
      return DartRemoteConfig(
          fetcher: _DebugFetcher(
            () => rootBundle.loadString("assets/remote_config/default.yaml"),
            () async => secondRemoteConfig,
            repo,
          ),
          versionProvider: () => EnvironmentHelper.kGitTag).create();
    }
  }

  return DartRemoteConfig(
      fetcher: S3Fetcher(repo,
          () => rootBundle.loadString("assets/remote_config/default.yaml")),
      versionProvider: () => EnvironmentHelper.kGitTag).create();
}

Future<String?> tryLoadingAsset(String path) async {
  try {
    return await rootBundle.loadString(path);
  } catch (_) {
    return null;
  }
}

class _DebugFetcher
    with RemoteConfigFetcherBase
    implements RemoteConfigFetcher {
  final RemoteConfigParser parser = const RemoteConfigParser();
  final RemoteConfigRepository repo;
  LoadFallbackRemoteConfig first, second;

  _DebugFetcher(this.first, this.second, this.repo);

  @override
  Future<RemoteConfigResponse> fetch() async {
    var lastRemoteConfig = await repo.readRemoteConfig();

    if (lastRemoteConfig == null) {
      await repo.saveRemoteConfig(await second());
      lastRemoteConfig = await first();
    }

    return fromYamlStringContent(lastRemoteConfig, parser);
  }
}
