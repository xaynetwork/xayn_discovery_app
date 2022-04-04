import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/base/identity_param.dart';

class LastSeenIdentityParam extends IdentityParam {
  LastSeenIdentityParam(DateTime time)
      : super(
          IdentityKeys.lastSeenDate,
          time.toIso8601String(),
        );
}
