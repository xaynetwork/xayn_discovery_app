import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_mixin.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_state.dart';
import 'package:xayn_discovery_app/presentation/premium/widgets/trial_expired.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with OverlayMixin<PaymentScreen> {
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
        builder: (_, state) => _buildScreen(state),
      );

  void _handlePurchasedOrRestored({
    required PaymentScreenState state,
    required BuildContext context,
  }) =>
      state.whenOrNull(ready: (product) {
        if (product.status.isPurchased || product.status.isRestored) {
          manager.onDismiss();
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

  Widget _buildTrialExpired(PurchasableProduct product) => Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).viewPadding.top,
          left: R.dimen.unit3,
          right: R.dimen.unit3,
        ),
        child: TrialExpired(
          product: product,
          onSubscribe: manager.subscribe,
          onPromoCode: () => manager.enterRedeemCode(),
          onRestore: manager.restore,
          padding: EdgeInsets.zero,
        ),
      );

  Widget _buildScreen(PaymentScreenState state) {
    final content = state.map(
      initial: (_) => _buildLoading(),
      ready: (state) => _buildTrialExpired(state.product),
      error: (_) {},
    );
    return Scaffold(
      body: SingleChildScrollView(child: content),
    );
  }
}
