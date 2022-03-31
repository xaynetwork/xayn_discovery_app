import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/base/identity_param.dart';

class NumberOfCollectionsIdentityParam extends IdentityParam {
  const NumberOfCollectionsIdentityParam(int numberOfCollections)
      : super(
          IdentityKeys.numberOfCollections,
          numberOfCollections,
        );
}
