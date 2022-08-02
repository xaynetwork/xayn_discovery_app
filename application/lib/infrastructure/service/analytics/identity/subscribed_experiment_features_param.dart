import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/base/identity_param.dart';

class SubscribedExperimentFeatureIdentityParam extends IdentityParam {
  const SubscribedExperimentFeatureIdentityParam(
    Set<String> experimentFeatureIds,
  ) : super(
          IdentityKeys.subscribedExperimentFeatureVariantIds,
          experimentFeatureIds,
        );
}
