import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_type.dart';

extension SubscriptionStatusExtension on SubscriptionStatus {
  SubscriptionType get subscriptionType {
    final now = DateTime.now();
    if (expirationDate?.isAfter(now) ?? false) {
      return SubscriptionType.subscribed;
    }

    if (trialEndDate?.isAfter(now) ?? false) {
      return SubscriptionType.freeTrial;
    }

    return SubscriptionType.notSubscribed;
  }

  bool get isSubscriptionActive =>
      subscriptionType == SubscriptionType.subscribed ||
      subscriptionType == SubscriptionType.promoCode;

  bool get isFreeTrialActive => subscriptionType == SubscriptionType.freeTrial;

  bool get isLastDayOfFreeTrial {
    if (subscriptionType != SubscriptionType.freeTrial) return false;
    final now = DateTime.now();
    return trialEndDate!.difference(now).inHours < 24;
  }
}
