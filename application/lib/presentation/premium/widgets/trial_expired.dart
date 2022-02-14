import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

/// A widget which we use to highlight the 'perks' of subscribing,
/// includes a number of handlers to cancel, subscribe or enter a promo code.
class TrialExpired extends StatelessWidget {
  /// The target product
  final PurchasableProduct _product;

  /// Handler for when the subscribe button was tapped.
  final VoidCallback _onSubscribe;

  /// Only applicable in [TrialExpired.embedded].
  /// Handler for when the cancel button was tapped.
  /// Use this to close the bottom sheet when it fires.
  final VoidCallback? _onCancel;

  /// Handler for when the promo code button was tapped.
  final VoidCallback _onPromoCode;

  const TrialExpired({
    Key? key,
    required PurchasableProduct product,
    required VoidCallback onSubscribe,
    required VoidCallback onPromoCode,
    VoidCallback? onCancel,
  })  : _product = product,
        _onSubscribe = onSubscribe,
        _onPromoCode = onPromoCode,
        _onCancel = onCancel,
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

  Widget _buildSubscribeNow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (_onCancel != null)
            Expanded(
              child: TextButton(
                  child: Text(
                    R.strings.bottomSheetCancel,
                    style: R.styles.appSecondaryButtonText,
                  ),
                  onPressed: _onCancel),
            ),
          SizedBox(
            width: R.dimen.unit,
          ),
          Expanded(
            child: AppRaisedButton.text(
              onPressed: _onSubscribe,
              text: R.strings.subscriptionSubscribeNow,
            ),
          ),
        ],
      );

  Widget _buildSubscriptionOptions() => Center(
        child: TextButton(
          child: Text(
            R.strings.subscriptionPromoCode,
            style: R.styles.appLinkText,
          ),
          onPressed: _onPromoCode,
        ),
      );

  Widget _buildFooter() => Text(
        R.strings.subscriptionDisclaimer,
        style: R.styles.subscriptionModalFooter,
      );
}
