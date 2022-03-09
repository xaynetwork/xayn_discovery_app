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

  /// Handler for when the cancel button was tapped.
  /// Use this to close the bottom sheet when it fires.
  /// If omitted, then the cancel button is not shown,
  /// which is only for the full screen version.
  final VoidCallback? _onCancel;

  /// Handler for when the promo code button was tapped.
  final VoidCallback _onPromoCode;

  /// Handler for when the restore button was tapped.
  final VoidCallback _onRestore;

  /// Custom content paddding.
  final EdgeInsetsGeometry? _padding;

  const TrialExpired({
    Key? key,
    required PurchasableProduct product,
    required VoidCallback onSubscribe,
    required VoidCallback onPromoCode,
    required VoidCallback onRestore,
    VoidCallback? onCancel,
    EdgeInsetsGeometry? padding,
  })  : _product = product,
        _onSubscribe = onSubscribe,
        _onPromoCode = onPromoCode,
        _onRestore = onRestore,
        _onCancel = onCancel,
        _padding = padding,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final spacer2_5 = SizedBox(height: R.dimen.unit2_5);
    final spacer3 = SizedBox(height: R.dimen.unit3);

    return SingleChildScrollView(
      child: Padding(
        padding: _padding ?? EdgeInsets.symmetric(horizontal: R.dimen.unit3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            spacer3,
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
        style: R.styles.lStyle,
      );

  Widget _buildPricing() => Text(
        _product.price,
        style: R.styles.xxxlBoldStyle,
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

  Widget _buildSubscribeNow() {
    final cancelButton = TextButton(
      child: Text(
        R.strings.bottomSheetCancel,
        style: R.styles.mBoldStyle.copyWith(
          color: R.colors.secondaryActionText,
        ),
      ),
      onPressed: _onCancel,
    );

    final spacer = SizedBox(
      width: R.dimen.unit,
    );

    final subscribeNowButton = AppRaisedButton.text(
      onPressed: _onSubscribe,
      text: R.strings.subscriptionSubscribeNow,
    );

    final loadingButton = AppRaisedButton(
      child: SizedBox(
        width: R.dimen.unit2_5,
        height: R.dimen.unit2_5,
        child: CircularProgressIndicator(
          color: R.colors.brightIcon,
          strokeWidth: R.dimen.unit0_25,
        ),
      ),
      onPressed: () {},
    );

    final isLoading = _product.status == PurchasableProductStatus.pending;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (_onCancel != null)
          Expanded(
            child: cancelButton,
          ),
        spacer,
        Expanded(
          child: isLoading ? loadingButton : subscribeNowButton,
        ),
      ],
    );
  }

  Widget _buildSubscriptionOptions() {
    final promoCode = TextButton(
      child: Text(
        R.strings.subscriptionPromoCode,
        style: R.styles.sBoldStyle.copyWith(
          decoration: TextDecoration.underline,
          color: R.colors.secondaryText,
        ),
      ),
      onPressed: _onPromoCode,
    );

    final spacer = SizedBox(
      width: R.dimen.unit,
    );

    final restore = TextButton(
      child: Text(
        R.strings.subscriptionRestore,
        style: R.styles.sBoldStyle.copyWith(
          decoration: TextDecoration.underline,
          color: R.colors.secondaryText,
        ),
      ),
      onPressed: _onRestore,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        promoCode,
        spacer,
        restore,
      ],
    );
  }

  Widget _buildFooter() => Text(
        R.strings.subscriptionDisclaimer,
        style: R.styles.sStyle.copyWith(
          color: R.colors.secondaryText,
        ),
      );
}
