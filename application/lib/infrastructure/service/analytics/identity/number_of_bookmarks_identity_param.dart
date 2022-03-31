import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/base/identity_param.dart';

class NumberOfBookmarksIdentityParam extends IdentityParam {
  const NumberOfBookmarksIdentityParam(int numberOfBookmarks)
      : super(
          IdentityKeys.numberOfBookmarks,
          numberOfBookmarks,
        );
}
