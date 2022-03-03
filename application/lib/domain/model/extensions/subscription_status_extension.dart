import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_type.dart';

extension SubscriptionStatusExtension on SubscriptionStatus {
  SubscriptionType get subscriptionType {
    final now = DateTime.now();
    if (expirationDate?.isAfter(now) ?? false) {
      return SubscriptionType.subscribed;
    }

    if (trialEndDate?.isAfter(now) ?? false) {
      if (trialEndDate!.difference(now).inHours < 24) {
        return SubscriptionType.lastDayOfFreeTrial;
      }
      return SubscriptionType.freeTrial;
    }

    return SubscriptionType.notSubscribed;
  }

  bool get isTrialActive =>
      subscriptionType == SubscriptionType.freeTrial ||
      subscriptionType == SubscriptionType.lastDayOfFreeTrial;

  bool get isSubscriptionActive =>
      subscriptionType == SubscriptionType.subscribed ||
      subscriptionType == SubscriptionType.subscribedWithPromoCode;
}
