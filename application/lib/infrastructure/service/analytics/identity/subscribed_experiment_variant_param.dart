import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/base/identity_param.dart';

class SubscribedExperimentVariantIdentityParam extends IdentityParam {
  const SubscribedExperimentVariantIdentityParam(
    List<String> experimentVariantIds,
  ) : super(
          IdentityKeys.subscribedExperimentVariantIds,
          experimentVariantIds,
        );
}
