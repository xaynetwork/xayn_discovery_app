import 'package:xayn_discovery_app/domain/model/payment/subscription_type.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/base/identity_param.dart';

enum AnalyticsSubscriptionType {
  promoCodeFreeTrialExtension,
  freeTrial,
  subscribed,
  notSubscribed,
}

extension AnalyticsSubscriptionTypeExtention on SubscriptionType {
  AnalyticsSubscriptionType get toAnalyticsType {
    switch (this) {
      case SubscriptionType.freeTrial:
        return AnalyticsSubscriptionType.freeTrial;
      case SubscriptionType.subscribed:
        return AnalyticsSubscriptionType.subscribed;
      case SubscriptionType.notSubscribed:
        return AnalyticsSubscriptionType.notSubscribed;
    }
  }
}

class SubscriptionTypeIdentityParam extends IdentityParam {
  SubscriptionTypeIdentityParam(AnalyticsSubscriptionType subscriptionType)
      : super(
          IdentityKeys.subscriptionType,
          subscriptionType.name,
        );
}
