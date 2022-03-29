import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/error/generic_error_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/error/no_active_subscription_found_error_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/error/payment_failed_error_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_state.dart';
import 'package:xayn_discovery_app/presentation/premium/widgets/trial_expired.dart';
import 'package:xayn_discovery_app/presentation/utils/error_code_extensions.dart';

class PaymentBottomSheet extends BottomSheetBase {
  PaymentBottomSheet({
    Key? key,
  }) : super(
          key: key,
          body: _Payment(),
        );
}

class _Payment extends StatelessWidget with BottomSheetBodyMixin {
  late final manager = di.get<PaymentScreenManager>();

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<PaymentScreenManager, PaymentScreenState>(
        bloc: manager,
        listener: (_, state) => _handlePurchasedOrRestored(
          state: state,
          context: context,
        ),
        builder: (_, state) => state.map(
          initial: (_) => _buildLoading(),
          error: (state) => GenericErrorBottomSheet(
            errorCode: state.error.errorCode,
          ),
          ready: (state) => _buildScreen(
            context: context,
            state: state,
          ),
        ),
      );

  void _handlePurchasedOrRestored({
    required PaymentScreenState state,
    required BuildContext context,
  }) =>
      state.whenOrNull(ready: (product, error) {
        if (product.status.isPurchased || product.status.isRestored) {
          closeBottomSheet(context);
        }
        if (error != null) _handleError(context, error);
        return null;
      });

  Widget _buildLoading() => SizedBox(
        height: R.dimen.unit52,
        child: Center(
          child: CircularProgressIndicator(
            color: R.colors.accent,
          ),
        ),
      );

  Widget _buildScreen({
    required BuildContext context,
    required PaymentScreenStateReady state,
  }) =>
      TrialExpired(
        product: state.product,
        onSubscribe: manager.subscribe,
        onPromoCode: () => manager.enterRedeemCode(),
        onRestore: manager.restore,
        onCancel: () => closeBottomSheet(context),
        padding: EdgeInsets.zero,
      );

  void _handleError(BuildContext context, PaymentFlowError error) {
    late BottomSheetBase body;
    if (error == PaymentFlowError.paymentFailed) {
      body = PaymentFailedErrorBottomSheet();
    } else if (error == PaymentFlowError.noActiveSubscriptionFound) {
      body = NoActiveSubscriptionFoundErrorBottomSheet();
    } else {
      body = GenericErrorBottomSheet(
        errorCode: error.errorCode,
      );
    }

    showAppBottomSheet(
      context,
      builder: (_) => body,
      allowStacking: true,
    );
  }
}
