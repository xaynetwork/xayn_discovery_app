import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_state.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/messages.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with TooltipStateMixin {
  late final manager = di.get<PaymentScreenManager>();

  @override
  void dispose() {
    manager.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void blocListener(BuildContext context, PaymentScreenState state) {
      state.whenOrNull(ready: (
        final PurchasableProduct product,
        final String? errorMsg,
      ) {
        if (errorMsg != null) {
          _showPaymentError(errorMsg);
        }
      });
    }

    final bloc = BlocBuilder<PaymentScreenManager, PaymentScreenState>(
      bloc: manager,
      builder: (_, state) => state.map(
        initial: (_) => const Center(),
        error: _buildErrorScreen,
        ready: _buildScreen,
      ),
    );
    return Scaffold(
      appBar: const AppToolbar(title: 'Payment screen'),
      body: BlocListener(
        bloc: manager,
        child: bloc,
        listener: blocListener,
      ),
    );
  }

  Widget _buildScreen(PaymentScreenStateReady state) {
    final product = state.product;
    final status = product.status.name;

    final tile = ListTile(
      title: Text(
        product.title,
        style: R.styles.appHeadlineText,
      ),
      subtitle: Text(
        product.description,
        style: R.styles.appCaptionText,
      ),
      trailing: Text(
        product.price,
        style: R.styles.appHeadlineText.copyWith(color: R.colors.accent),
      ),
    );

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('status: $status'),
        const SizedBox(height: 100),
        tile,
        const SizedBox(height: 100),
        product.canBePurchased
            ? AppGhostButton.text('APPLY', onPressed: manager.subscribe)
            : const Center(),
        Platform.isIOS
            ? AppGhostButton.text(
                'enter redeem code',
                onPressed: manager.enterRedeemCode,
              )
            : const Center(),
      ],
    );
    return Center(child: column);
  }

  void _showPaymentError(String paymentErrorMsg) {
    registerTooltip(
      key: TooltipKeys.paymentError,
      params: TooltipParams(
        label: paymentErrorMsg,
        builder: (_) => const TextualNotification(),
      ),
    );
    showTooltip(TooltipKeys.paymentError);
  }

  Widget _buildErrorScreen(PaymentScreenStateError stateError) {
    final text = Text(stateError.errorMsg);
    return Center(child: text);
  }
}
