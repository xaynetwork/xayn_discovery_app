import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_state.dart';
import 'package:xayn_discovery_app/presentation/premium/widgets/trial_expired.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_mixin.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({Key? key}) : super(key: key);

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen>
    with OverlayMixin<PaywallScreen> {
  late final manager = di.get<PaywallScreenManager>();

  @override
  OverlayManager get overlayManager => manager.overlayManager;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PaymentScreenManager, PaymentScreenState>(
        bloc: manager,
        builder: (_, state) => _buildScreen(state),
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
