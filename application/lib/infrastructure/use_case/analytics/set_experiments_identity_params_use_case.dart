import 'package:dart_remote_config/model/experimentation_engine_result.dart';
import 'package:dart_remote_config/utils/extensions.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/subscribed_experiment_features_param.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/subscribed_experiment_variant_param.dart';

@injectable
class SetExperimentsIdentityParamsUseCase
    extends UseCase<ExperimentationEngineResult, None> {
  final AnalyticsService _analyticsService;

  SetExperimentsIdentityParamsUseCase(
    this._analyticsService,
  );

  @override
  Stream<None> transaction(ExperimentationEngineResult param) async* {
    final variants = SubscribedExperimentVariantIdentityParam(
      param.subscribedVariantIds
          .map((it) => '${it.experimentId}__${it.variantId!}')
          .toSet(),
    );

    final features = SubscribedExperimentFeatureIdentityParam(
      param.enabledFeatures.map((it) => it.id).toSet(),
    );

    await _analyticsService.updateIdentityParams({variants, features});

    yield none;
  }
}
