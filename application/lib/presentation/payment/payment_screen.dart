import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_state.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final manager = di.get<PaymentScreenManager>();

  @override
  void dispose() {
    manager.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocBuilder<PaymentScreenManager, PaymentScreenState>(
      bloc: manager,
      builder: (_, state) => state.map(
        initial: (_) => const Center(),
        ready: _buildScreen,
      ),
    );
    return Scaffold(
      appBar: const AppToolbar(title: 'Payment screen'),
      body: bloc,
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
        style: R.styles.appHeadlineText?.copyWith(color: R.colors.accent),
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
      ],
    );
    return Center(child: column);
  }
}
