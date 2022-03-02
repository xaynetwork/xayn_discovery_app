class SubscriptionStatus {
  final bool willRenew;
  final DateTime? expirationDate;

  const SubscriptionStatus({
    required this.willRenew,
    required this.expirationDate,
  });

  bool get isSubscriptionActive =>
      expirationDate?.isAfter(DateTime.now()) ?? false;

  // TODO: implement trial functionality
  DateTime? get trialEndDate => expirationDate;

  bool get isTrialActive => trialEndDate?.isAfter(DateTime.now()) ?? false;
}
