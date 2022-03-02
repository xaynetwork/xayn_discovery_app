class SubscriptionStatus {
  final bool willRenew;
  final DateTime? expirationDate;

  const SubscriptionStatus({
    required this.willRenew,
    required this.expirationDate,
  });

  bool get isActive => expirationDate != null;

  // TODO: implement trial functionality
  DateTime? get trialEndDate => expirationDate;
}
