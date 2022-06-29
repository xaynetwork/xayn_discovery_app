import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_type.dart';
import 'package:xayn_discovery_app/presentation/utils/real_time.dart';

extension SubscriptionStatusExtension on SubscriptionStatus {
  SubscriptionType get subscriptionType {
    RealTime().updateTime();

    if (isBetaUser) {
      return SubscriptionType.subscribed;
    }

    if (expirationDate?.isAfter(RealTime().now) ?? false) {
      return SubscriptionType.subscribed;
    }

    if (trialEndDate?.isAfter(RealTime().now) ?? false) {
      return SubscriptionType.freeTrial;
    }

    return SubscriptionType.notSubscribed;
  }

  bool get isSubscriptionActive =>
      subscriptionType == SubscriptionType.subscribed;

  bool get isFreeTrialActive => subscriptionType == SubscriptionType.freeTrial;

  bool get isLastDayOfFreeTrial {
    if (subscriptionType != SubscriptionType.freeTrial) return false;
    return trialEndDate!.difference(RealTime().now).inHours < 24;
  }
}
