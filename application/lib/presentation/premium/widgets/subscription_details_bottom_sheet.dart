import 'dart:io';

import 'package:flutter/material.dart';
import 'package:super_rich_text/super_rich_text.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_type.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/constants/urls.dart';
import 'package:xayn_discovery_app/presentation/utils/datetime_utils.dart';

const String _kTextPlaceholder = '__';

class SubscriptionDetailsBottomSheet extends BottomSheetBase {
  SubscriptionDetailsBottomSheet({
    Key? key,
    required SubscriptionStatus subscriptionStatus,
  }) : super(
          key: key,
          body: _SubscriptionDetails(
            subscriptionStatus: subscriptionStatus,
          ),
        );
}

class _SubscriptionDetails extends StatelessWidget with BottomSheetBodyMixin {
  final SubscriptionStatus subscriptionStatus;

  const _SubscriptionDetails({
    Key? key,
    required this.subscriptionStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spacer0_5 = SizedBox(height: R.dimen.unit0_5);
    final spacer2 = SizedBox(height: R.dimen.unit2);
    final spacer3 = SizedBox(height: R.dimen.unit3);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        spacer3,
        _buildHeader(),
        spacer0_5,
        _buildTitle(),
        spacer2,
        _buildInfo(),
        spacer2,
        _buildFooter(),
        spacer2,
        _buildDoneButton(context),
      ],
    );
  }

  Widget _buildHeader() => Text(
        R.strings.settingsSubscribedToHeader,
        style: R.styles.lStyle,
      );

  Widget _buildTitle() => Text(
        R.strings.settingsXaynPremium,
        style: R.styles.xlBoldStyle,
      );

  Widget _buildInfo() {
    final dateString = subscriptionStatus.expirationDate?.shortDateFormat ?? '';
    final infoString =
        subscriptionStatus.subscriptionType == SubscriptionType.promoCode
            ? R.strings.promoCodeValidUntilText
            : R.strings.subscriptionRenewsMonthlyText;
    final infoStringWithDate = infoString.replaceFirst(
        '%s', '$_kTextPlaceholder$dateString$_kTextPlaceholder');
    return SuperRichText(
      text: infoStringWithDate,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: R.styles.mStyle,
      othersMarkers: [
        MarkerText(
          marker: _kTextPlaceholder,
          style: R.styles.mStyle.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final footerString = Platform.isIOS
        ? R.strings.subscriptionPlatformInfoApple
        : R.strings.subscriptionPlatformInfoGoogle;
    final url = Platform.isIOS
        ? Urls.subscriptionCancelApple
        : Urls.subscriptionCancelGoogle;
    return SuperRichText(
      text: footerString,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: R.styles.dialogBodySmall,
      othersMarkers: [
        MarkerText.withUrl(
          marker: _kTextPlaceholder,
          urls: [url],
          style:
              R.styles.dialogBodySmall.copyWith(color: R.colors.primaryAction),
        ),
      ],
    );
  }

  Widget _buildDoneButton(BuildContext context) => AppGhostButton.text(
        R.strings.doneButtonTitle,
        onPressed: () => closeBottomSheet(context),
      );
}
