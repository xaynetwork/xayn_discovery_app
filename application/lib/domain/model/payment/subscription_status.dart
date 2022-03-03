class SubscriptionStatus {
  final bool willRenew;
  final DateTime? expirationDate;
  final DateTime? trialEndDate;

  const SubscriptionStatus({
    required this.willRenew,
    required this.expirationDate,
    required this.trialEndDate,
  });

  factory SubscriptionStatus.initial() => const SubscriptionStatus(
        willRenew: false,
        expirationDate: null,
        trialEndDate: null,
      );
}
