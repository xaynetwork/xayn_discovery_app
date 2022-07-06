import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/remote_config/check_remote_config_promo_code_use_case.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/promo_code/manager/redeem_promo_code_state.dart';

@injectable
class RedeemPromoCodeManager extends Cubit<RedeemPromoCodeState>
    with UseCaseBlocHelper<RedeemPromoCodeState> {
  RedeemPromoCodeManager(
    this._checkRemoteConfigPromoCode,
  ) : super(const RedeemPromoCodeState.initial());

  final CheckRemoteConfigPromoCodeUseCase _checkRemoteConfigPromoCode;
  late final _checkPromoCodeHandler = pipe(_checkRemoteConfigPromoCode);
  String lastTypedCode = '';
  String? lastAppliedCode;

  void redeemPromoCode(String code) {
    lastAppliedCode = code;
    _checkPromoCodeHandler(code);
  }

  void onPromoCodeTyped(String code) {
    if (lastTypedCode != lastAppliedCode) {
      scheduleComputeState(() {
        lastAppliedCode = null;
      });
    }
    lastTypedCode = code;
  }

  @override
  Future<RedeemPromoCodeState> computeState() async =>
      fold(_checkPromoCodeHandler).foldAll((res, errorReport) {
        final promoCode = res?.promoCode;
        final alreadyUsed = res?.alreadyUsed ?? false;
        RedeemPromoCodeError? error;

        if (alreadyUsed) {
          error = RedeemPromoCodeError.alreadyUsedPromoCode;
        } else if (promoCode != null &&
            !promoCode.isValid &&
            lastAppliedCode != null) {
          error = RedeemPromoCodeError.expiredPromoCode;
        } else if (promoCode == null && lastAppliedCode != null) {
          error = RedeemPromoCodeError.unknownPromoCode;
        }

        if (promoCode != null && error == null) {
          return RedeemPromoCodeState.successful(promoCode);
        } else if (error != null) {
          return RedeemPromoCodeState.error(error);
        } else {
          return const RedeemPromoCodeState.initial();
        }
      });
}
