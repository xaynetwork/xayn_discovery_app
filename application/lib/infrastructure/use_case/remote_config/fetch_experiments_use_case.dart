import 'package:dart_remote_config/dart_remote_config.dart';
import 'package:dart_remote_config/model/feature.dart';
import 'package:dart_remote_config/model/known_experiment_variant.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xayn_architecture/xayn_architecture.dart';

class FetchedExperimentsOut extends Equatable {
  const FetchedExperimentsOut(
    this.subscribedVariantIds,
    this.subscribedFeatures,
  );

  final Set<KnownVariantId> subscribedVariantIds;
  final Set<Feature> subscribedFeatures;

  @override
  List<Object?> get props => [subscribedVariantIds, subscribedFeatures];
}

@injectable
class FetchExperimentsUseCase extends UseCase<None, FetchedExperimentsOut> {
  FetchExperimentsUseCase(
    this._fetcher,
    this._packageInfo,
  );

  final PackageInfo _packageInfo;
  final RemoteConfigFetcher _fetcher;

  @override
  Stream<FetchedExperimentsOut> transaction(None param) async* {
    final configFactory = DartRemoteConfig(
      fetcher: _fetcher,
      versionProvider: () => _packageInfo.version,
    );
    final config = await configFactory.create();
    yield config.map(
      success: (success) {
        return FetchedExperimentsOut(
          success.experiments.subscribedVariantIds,
          success.experiments.enabledFeatures,
        );
      },
      failed: (failed) {
        return const FetchedExperimentsOut({}, {});
      },
    );
  }
}
