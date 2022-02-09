import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';

part 'payment_screen_state.freezed.dart';

@freezed
class PaymentScreenState with _$PaymentScreenState {
  const factory PaymentScreenState.initial() = _Initial;

  const factory PaymentScreenState.ready({
    required PurchasableProduct product,
    required String? errorMsg,
  }) = PaymentScreenStateReady;
}
