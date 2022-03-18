enum PaymentFlowError {
  canceled,
  unknown,
  storeNotAvailable,
  productNotFound,
  itemAlreadyOwned,
  paymentFailed,
  noActiveSubscriptionFound,
}

extension PaymentFlowErrorExtension on PaymentFlowError {
  bool get itemAlreadyOwned => this == PaymentFlowError.itemAlreadyOwned;
}
