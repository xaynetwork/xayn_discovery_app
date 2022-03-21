import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/base/identity_param.dart';

class NumberOfTotalSessionIdentityParam extends IdentityParam {
  const NumberOfTotalSessionIdentityParam(int numberOfTotalSessions)
      : super(
          IdentityKeys.numberOfTotalSession,
          numberOfTotalSessions,
        );
}
