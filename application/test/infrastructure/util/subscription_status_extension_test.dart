import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_type.dart';

void main() {
  test('Beta user should have active subscription: ', () {
    const status = SubscriptionStatus(
      willRenew: false,
      expirationDate: null,
      trialEndDate: null,
      purchaseDate: null,
      isBetaUser: true,
    );
    expect(status.subscriptionType, SubscriptionType.subscribed);
  });

  test(
      'When expirationDate is in the future then the user should have active subscription: ',
      () {
    final status = SubscriptionStatus(
      willRenew: false,
      expirationDate: DateTime.now().add(const Duration(days: 1)),
      trialEndDate: null,
      purchaseDate: null,
      isBetaUser: false,
    );
    expect(status.subscriptionType, SubscriptionType.subscribed);
  });

  test(
      'When expirationDate is in the past then the user should not have active subscription: ',
      () {
    final status = SubscriptionStatus(
      willRenew: false,
      expirationDate: DateTime.now().subtract(const Duration(days: 1)),
      trialEndDate: null,
      purchaseDate: null,
      isBetaUser: false,
    );
    expect(status.subscriptionType, SubscriptionType.notSubscribed);
  });

  test(
      'When trialEndDate is in the future then the user should have active trial: ',
      () {
    final status = SubscriptionStatus(
      willRenew: false,
      expirationDate: null,
      trialEndDate: DateTime.now().add(const Duration(days: 1)),
      purchaseDate: null,
      isBetaUser: false,
    );
    expect(status.subscriptionType, SubscriptionType.freeTrial);
  });

  test(
      'When trialEndDate is in the past then the user should not have active subscription: ',
      () {
    final status = SubscriptionStatus(
      willRenew: false,
      expirationDate: null,
      trialEndDate: DateTime.now().subtract(const Duration(days: 1)),
      purchaseDate: null,
      isBetaUser: false,
    );
    expect(status.subscriptionType, SubscriptionType.notSubscribed);
  });
}
