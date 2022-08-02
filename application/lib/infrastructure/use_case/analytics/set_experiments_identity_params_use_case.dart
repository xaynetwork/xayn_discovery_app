import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/subscribed_experiment_features_param.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/subscribed_experiment_variant_param.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/remote_config/fetch_experiments_use_case.dart';

@injectable
class SetExperimentsIdentityParamsUseCase
    extends UseCase<FetchedExperimentsOut, None> {
  final AnalyticsService _analyticsService;

  SetExperimentsIdentityParamsUseCase(
    this._analyticsService,
  );

  @override
  Stream<None> transaction(FetchedExperimentsOut param) async* {
    final variants = SubscribedExperimentVariantIdentityParam(
      param.subscribedVariantIds
          .map((it) => '${it.experimentId}__${it.variantId!}')
          .toSet(),
    );

    final features = SubscribedExperimentFeatureIdentityParam(
      param.subscribedFeatures.map((it) => it.id).toSet(),
    );

    await _analyticsService.updateIdentityParams({variants, features});

    yield none;
  }
}
