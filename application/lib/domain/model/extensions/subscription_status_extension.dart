import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_type.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/utils/real_time.dart';

extension SubscriptionStatusExtension on SubscriptionStatus {
  RealTime get _realTime => di.get();

  SubscriptionType get subscriptionType {
    _realTime.updateTime();

    if (isBetaUser) {
      return SubscriptionType.subscribed;
    }

    if (expirationDate?.isAfter(_realTime.now) ?? false) {
      return SubscriptionType.subscribed;
    }

    if (trialEndDate?.isAfter(_realTime.now) ?? false) {
      return SubscriptionType.freeTrial;
    }

    return SubscriptionType.notSubscribed;
  }

  bool get isSubscriptionActive =>
      subscriptionType == SubscriptionType.subscribed;

  bool get isFreeTrialActive => subscriptionType == SubscriptionType.freeTrial;

  bool get isLastDayOfFreeTrial {
    if (subscriptionType != SubscriptionType.freeTrial) return false;
    return trialEndDate!.difference(_realTime.now).inHours < 24;
  }
}
