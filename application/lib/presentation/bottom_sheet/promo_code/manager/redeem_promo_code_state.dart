import 'package:dart_remote_config/dart_remote_config.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'redeem_promo_code_state.freezed.dart';

enum RedeemPromoCodeError {
  unknownPromoCode,
  expiredPromoCode,
  alreadyUsedPromoCode;
}

@freezed
class RedeemPromoCodeState with _$RedeemPromoCodeState {
  const factory RedeemPromoCodeState.initial() = _Initial;

  const factory RedeemPromoCodeState.error(RedeemPromoCodeError error) =
      RedeemPromoCodeStateError;

  const factory RedeemPromoCodeState.successful(PromoCode code) = _Sucessful;
}
