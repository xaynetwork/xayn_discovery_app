import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/error/generic_error_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_state.dart';
import 'package:xayn_discovery_app/presentation/premium/widgets/trial_expired.dart';
import 'package:xayn_discovery_app/presentation/utils/error_code_extensions.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_mixin.dart';

class PaymentBottomSheet extends BottomSheetBase {
  PaymentBottomSheet({
    Key? key,
    required VoidCallback onClosePressed,
    required VoidCallback? onRedeemPressed,
  }) : super(
          key: key,
          body: PaymentBottomSheetBody(onClosePressed, onRedeemPressed),
          onSystemPop: onClosePressed,
        );
}

class PaymentBottomSheetBody extends StatefulWidget {
  final VoidCallback onClosePressed;
  final VoidCallback? onRedeemPressed;

  const PaymentBottomSheetBody(
    this.onClosePressed,
    this.onRedeemPressed, {
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentBottomSheetBody> createState() => _PaymentBottomSheetBodyState();
}

class _PaymentBottomSheetBodyState extends State<PaymentBottomSheetBody>
    with BottomSheetBodyMixin, OverlayMixin<PaymentBottomSheetBody> {
  late final manager = di.get<BottomSheetPaymentScreenManager>()
    ..dismissBottomSheet = () {
      closeBottomSheet(context);
    };

  @override
  OverlayManager get overlayManager => manager.overlayManager;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PaymentScreenManager, PaymentScreenState>(
        bloc: manager,
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
        onPromoCode: () {
          if (widget.onRedeemPressed != null) {
            widget.onRedeemPressed!();
            closeBottomSheet(context);
          } else {
            manager.enterRedeemCode();
          }
        },
        onRestore: manager.restore,
        onCancel: () {
          manager.cancel();
          closeBottomSheet(context);
          widget.onClosePressed();
        },
        padding: EdgeInsets.zero,
      );
}
