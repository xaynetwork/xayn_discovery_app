import 'package:xayn_discovery_app/domain/model/payment/subscription_type.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/base/identity_param.dart';

class SubscriptionTypeIdentityParam extends IdentityParam {
  SubscriptionTypeIdentityParam(SubscriptionType subscriptionType)
      : super(
          IdentityKeys.subscriptionType,
          subscriptionType.name,
        );
}
