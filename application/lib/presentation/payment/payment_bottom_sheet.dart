import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
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
      BlocBuilder<PaymentScreenManager, PaymentScreenState>(
        bloc: manager,
        builder: (_, state) => state.map(
          initial: (_) => _buildLoading(),
          error: _buildErrorScreen,
          ready: (state) => _buildScreen(
            context: context,
            state: state,
          ),
        ),
      );

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
        onCancel: () => closeBottomSheet(context),
        padding: EdgeInsets.zero,
      );

  Widget _buildErrorScreen(PaymentScreenStateError stateError) {
    final text = Text(stateError.errorMsg);
    return Center(child: text);
  }
}
