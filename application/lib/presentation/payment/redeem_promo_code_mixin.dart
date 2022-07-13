import 'package:dart_remote_config/dart_remote_config.dart';
import 'package:xayn_discovery_app/domain/model/extensions/app_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_type.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_redeem_code_window_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/redeem_code_action_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/subscription_type_identity_param.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/set_identity_param_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/remote_config/apply_promo_code_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager_mixin.dart';

mixin RedeemPromoCodeMixin<T> on OverlayManagerMixin<T> {
  late final ApplyPromoCodeUseCase _applyPromoCodeUseCase = di.get();
  late final SendAnalyticsUseCase _analytics = di.get();
  late final SetIdentityParamUseCase _params = di.get();
  late final AppStatusRepository _appStatus = di.get();

  void redeemAlternativeCodeFlow() {
    _analytics.singleOutput(OpenRedeemCodeWindowEvent());
    int trialTimeLeft =
        _appStatus.appStatus.trialEndDate.difference(DateTime.now()).inDays;

    showOverlay(
        OverlayData.bottomSheetAlternativePromoCode((PromoCode code) async {
      final success = await _applyPromoCodeUseCase.singleOutput(code);
      _analytics.singleOutput(RedeemCodeActionEvent(
        action: success ? RedeemAction.applied : RedeemAction.error,
        code: code.code,
        trialDaysLeftWhenEntering: trialTimeLeft,
      ));
      if (success) {
        _params.singleOutput(SubscriptionTypeIdentityParam(
            SubscriptionType.promoCodeFreeTrialExtension));
        showOverlay(OverlayData.bottomSheetPromoCodeApplied(code));
      }
    }, onCancel: () {
      _analytics.singleOutput(RedeemCodeActionEvent(
        action: RedeemAction.cancel,
        trialDaysLeftWhenEntering: trialTimeLeft,
      ));
    }));
  }
}
