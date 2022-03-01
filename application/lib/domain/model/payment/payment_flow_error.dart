enum PaymentFlowError {
  canceled,
  unknown,
  storeNotAvailable,
  productNotFound,
  itemAlreadyOwned,
  paymentFailed,
}

extension PaymentFlowErrorExtension on PaymentFlowError {
  bool get itemAlreadyOwned => this == PaymentFlowError.itemAlreadyOwned;
}
