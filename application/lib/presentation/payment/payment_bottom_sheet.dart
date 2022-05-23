import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/error/generic_error_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_mixin.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_state.dart';
import 'package:xayn_discovery_app/presentation/premium/widgets/trial_expired.dart';
import 'package:xayn_discovery_app/presentation/utils/error_code_extensions.dart';

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

class _Payment extends StatefulWidget {
  final VoidCallback onClosePressed;

  const _Payment(this.onClosePressed);

  @override
  State<_Payment> createState() => _PaymentState();
}

class _PaymentState extends State<_Payment>
    with BottomSheetBodyMixin, OverlayMixin<_Payment> {
  late final manager = di.get<PaymentScreenManager>();

  @override
  OverlayManager get overlayManager => manager.overlayManager;

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
      state.whenOrNull(ready: (product) {
        if (product.status.isPurchased || product.status.isRestored) {
          closeBottomSheet(context);
          widget.onClosePressed();
        }
        return null;
      });

  Widget _buildLoading() => SizedBox(
        height: R.dimen.unit20,
        child: Center(
          child: CircularProgressIndicator(
            color: R.colors.icon,
            strokeWidth: R.dimen.unit0_25,
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
          widget.onClosePressed();
        },
        padding: EdgeInsets.zero,
      );
}
