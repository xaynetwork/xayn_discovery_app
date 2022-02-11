import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_manager.dart';

class TrialExpired extends StatelessWidget {
  final PurchasableProduct _product;
  late final PaymentScreenManager _paymentScreenManager = di.get();

  TrialExpired({
    Key? key,
    required PurchasableProduct product,
  })  : _product = product,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final spacer2_5 = SizedBox(height: R.dimen.unit2_5);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitle(),
            _buildPricing(),
            _buildPerks(),
            spacer2_5,
            _buildSubscribeNow(),
            _buildSubscriptionOptions(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() => Text(
        R.strings.subscriptionHeader,
        style: R.styles.subscriptionModalTitle,
      );

  Widget _buildPricing() => Text(
        _product.price,
        style: R.styles.subscriptionModalPrice,
      );

  Widget _buildPerks() => SettingsSection(
      topPadding: .0,
      items: [
        R.strings.subscriptionPerk1,
        R.strings.subscriptionPerk2,
        R.strings.subscriptionPerk3,
        R.strings.subscriptionPerk4,
        R.strings.subscriptionPerk5,
      ]
          .map(
            (it) => SettingsTileData(
              title: it,
              svgIconPath: R.assets.icons.check,
            ),
          )
          .map((it) => SettingsCardData.fromTile(it))
          .toList(growable: false));

  Widget _buildSubscribeNow() => AppRaisedButton.text(
        onPressed: _paymentScreenManager.subscribe,
        text: R.strings.subscriptionSubscribeNow,
      );

  Widget _buildSubscriptionOptions() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: TextButton(
              child: Text(
                R.strings.subscriptionRestore,
                style: R.styles.appLinkText,
              ),
              onPressed: () {
                // todo: implement restore subscription
              },
            ),
          ),
          SizedBox(
            width: R.dimen.unit,
          ),
          Expanded(
            child: TextButton(
              child: Text(
                R.strings.subscriptionPromoCode,
                style: R.styles.appLinkText,
              ),
              onPressed: () {
                // todo: implement promo code
              },
            ),
          ),
        ],
      );

  Widget _buildFooter() => Text(
        R.strings.subscriptionDisclaimer,
        style: R.styles.subscriptionModalFooter,
      );
}
