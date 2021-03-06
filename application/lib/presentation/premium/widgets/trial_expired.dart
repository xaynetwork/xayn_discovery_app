import 'dart:io';

import 'package:flutter/material.dart';
import 'package:super_rich_text/super_rich_text.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/constants.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';

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

  /// Custom content padding.
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
            spacer3,
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() => Text(
        R.strings.subscriptionHeader,
        style: R.styles.lStyle,
      );

  Widget _buildPricing() {
    final price = _product.duration != null
        ? '${_product.price}/${_product.duration}'
        : _product.price;
    return Text(
      price,
      style: R.styles.xxlBoldStyle,
    );
  }

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

  Widget _buildProgressIndicator(Color color) => SizedBox(
        width: R.dimen.unit2_5,
        height: R.dimen.unit2_5,
        child: CircularProgressIndicator(
          color: color,
          strokeWidth: R.dimen.unit0_25,
        ),
      );

  Widget _buildSubscribeNow() {
    final cancelButton = AppGhostButton.text(
      R.strings.bottomSheetCancel,
      onPressed: _onCancel,
      backgroundColor: R.colors.bottomSheetCancelBackgroundColor,
    );

    final spacer = SizedBox(
      width: R.dimen.unit,
    );

    final isPurchasing =
        _product.status == PurchasableProductStatus.purchasePending;

    final subscribeNowButton = AppRaisedButton(
      onPressed: _onSubscribe,
      child: SizedBox(
        height: R.dimen.unit3,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPurchasing) ...[
              _buildProgressIndicator(R.colors.brightIcon),
              spacer
            ],
            Text(
              R.strings.subscriptionSubscribeNow,
              style: R.styles.buttonTextBright,
            ),
          ],
        ),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (_onCancel != null)
          Expanded(
            child: cancelButton,
          ),
        spacer,
        Expanded(
          child: subscribeNowButton,
        ),
      ],
    );
  }

  Widget _buildSubscriptionOptions() {
    final FeatureManager featureManager = di.get();
    final spacer = SizedBox(
      width: R.dimen.unit,
    );

    final isRestoring =
        _product.status == PurchasableProductStatus.restorePending;

    final restore = TextButton(
      onPressed: _onRestore,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isRestoring) ...[
            _buildProgressIndicator(R.colors.secondaryText),
            spacer,
          ],
          Text(
            R.strings.subscriptionRestore,
            style: R.styles.sBoldStyle.copyWith(
              decoration: TextDecoration.underline,
              color: R.colors.secondaryText,
            ),
          ),
        ],
      ),
    );

    if (!Platform.isIOS && !featureManager.isAlternativePromoCodeEnabled) {
      return Center(child: restore);
    }

    final promoCode = TextButton(
      onPressed: _onPromoCode,
      child: Text(
        R.strings.subscriptionPromoCode,
        style: R.styles.sBoldStyle.copyWith(
          decoration: TextDecoration.underline,
          color: R.colors.secondaryText,
        ),
      ),
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

  Widget _buildFooter() => SuperRichText(
        text: R.strings.subscriptionDisclaimer,
        style: R.styles.sStyle.copyWith(
          color: R.colors.secondaryText,
        ),
        othersMarkers: [
          MarkerText.withUrl(
            marker: '__',
            urls: [
              Constants.termsAndConditionsUrl,
              Constants.privacyPolicyUrl,
            ],
            style: R.styles.sStyle.copyWith(
              color: R.colors.primaryAction,
            ),
          ),
        ],
      );
}
