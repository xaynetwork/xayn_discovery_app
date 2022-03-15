import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_status.freezed.dart';

@freezed
class SubscriptionStatus with _$SubscriptionStatus {
  const factory SubscriptionStatus({
    required bool willRenew,
    required DateTime? expirationDate,
    required DateTime? trialEndDate,
  }) = _SubscriptionStatus;

  factory SubscriptionStatus.initial() => const SubscriptionStatus(
        willRenew: false,
        expirationDate: null,
        trialEndDate: null,
      );
}
