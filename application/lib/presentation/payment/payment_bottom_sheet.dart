import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_state.dart';
import 'package:xayn_discovery_app/presentation/premium/widgets/trial_expired.dart';

class PaymentBottomSheet extends BottomSheetBase {
  PaymentBottomSheet({
    Key? key,
    required VoidCallback onClosePressed,
  }) : super(
          key: key,
          body: _Payment(onClosePressed),
          onSystemPop: onClosePressed,
        );
}

class _Payment extends StatelessWidget with BottomSheetBodyMixin {
  late final manager = di.get<PaymentScreenManager>();
  final VoidCallback onClosePressed;

  _Payment(this.onClosePressed);

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
          error: _buildErrorScreen,
          ready: (state) => _buildScreen(
            context: context,
            state: state,
          ),
        ),
      );

  void _handlePurchasedOrRestored({
    required PaymentScreenState state,
    required BuildContext context,
  }) {
    // When the user purchases or restores subscription - dismiss the bottom sheet
    state.whenOrNull(ready: (product, _) {
      if (product.status.isPurchased || product.status.isRestored) {
        closeBottomSheet(context);
        onClosePressed();
      }
    });
  }

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
        onPromoCode: manager.enterRedeemCode,
        onRestore: manager.restore,
        onCancel: () {
          manager.cancel();
          closeBottomSheet(context);
          onClosePressed();
        },
        padding: EdgeInsets.zero,
      );

  Widget _buildErrorScreen(PaymentScreenStateError stateError) {
    final text = Text(stateError.errorMsg);
    return Center(child: text);
  }
}
