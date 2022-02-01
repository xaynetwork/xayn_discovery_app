part of 'payment_screen_manager.dart';

@freezed
class PaymentScreenState with _$PaymentScreenState {
  const factory PaymentScreenState.initial() = _Initial;

  const factory PaymentScreenState.ready({
    required PurchasableProduct product,
    required String? errorMsg,
  }) = PaymentScreenStateReady;
}
