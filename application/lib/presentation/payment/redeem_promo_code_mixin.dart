import 'package:dart_remote_config/dart_remote_config.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/remote_config/apply_promo_code_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager_mixin.dart';

mixin RedeemPromoCodeMixin<T> on OverlayManagerMixin<T> {
  late final ApplyPromoCodeUseCase _applyPromoCodeUseCase = di.get();

  void redeemAlternativeCodeFlow() {
    showOverlay(
        OverlayData.bottomSheetAlternativePromoCode((PromoCode code) async {
      final success = await _applyPromoCodeUseCase.singleOutput(code);
      if (success) {
        showOverlay(OverlayData.bottomSheetPromoCodeApplied(code));
      }
    }));
  }
}
