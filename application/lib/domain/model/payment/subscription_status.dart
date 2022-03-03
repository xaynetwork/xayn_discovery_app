class SubscriptionStatus {
  final bool willRenew;
  final DateTime? expirationDate;
  final DateTime? trialEndDate;

  const SubscriptionStatus({
    required this.willRenew,
    required this.expirationDate,
    required this.trialEndDate,
  });
}
