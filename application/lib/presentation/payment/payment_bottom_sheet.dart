import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/error/generic_error_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/error/payment_failed_error_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/payment_promo_code/payment_promo_code_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_state.dart';
import 'package:xayn_discovery_app/presentation/premium/widgets/trial_expired.dart';

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
          error: (state) {
            if (state.error == PaymentFlowError.paymentFailed) {
              return PaymentFailedErrorBottomSheet();
            }
            return GenericErrorBottomSheet();
          },
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
        if (error != null) {
          final paymentFailed = error == PaymentFlowError.paymentFailed;
          final body = paymentFailed
              ? PaymentFailedErrorBottomSheet()
              : GenericErrorBottomSheet();
          showAppBottomSheet(
            context,
            builder: (_) => body,
            allowStacking: true,
          );
        }
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
        onPromoCode: () => _onPromoCode(context),
        onRestore: manager.restore,
        onCancel: () => closeBottomSheet(context),
        padding: EdgeInsets.zero,
      );

  void _onPromoCode(BuildContext context) {
    if (Platform.isIOS) {
      manager.enterRedeemCode();
    } else {
      showAppBottomSheet(
        context,
        builder: (_) => PaymentPromoCodeBottomSheet(),
        allowStacking: true,
      );
    }
  }
}
