import 'dart:io';

import 'package:flutter/material.dart';
import 'package:super_rich_text/super_rich_text.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/utils/datetime_utils.dart';

enum SubscriptionType {
  paid,
  promoCode,
}

class SubscriptionDetailsBottomSheet extends BottomSheetBase {
  SubscriptionDetailsBottomSheet({
    Key? key,
    required SubscriptionType subscriptionType,
    required DateTime endDate,
    required VoidCallback onCancelSubscriptionPressed,
  }) : super(
          key: key,
          body: _SubscriptionDetails(
            subscriptionType: subscriptionType,
            endDate: endDate,
            onCancelSubscriptionPressed: onCancelSubscriptionPressed,
          ),
        );
}

class _SubscriptionDetails extends StatelessWidget with BottomSheetBodyMixin {
  final SubscriptionType subscriptionType;
  final DateTime endDate;
  final VoidCallback onCancelSubscriptionPressed;

  const _SubscriptionDetails({
    Key? key,
    required this.subscriptionType,
    required this.endDate,
    required this.onCancelSubscriptionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spacer0_5 = SizedBox(height: R.dimen.unit0_5);
    final spacer1_5 = SizedBox(height: R.dimen.unit1_5);
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
        spacer1_5,
        _buildFooter(),
        spacer2,
        _buildDoneButton(context),
      ],
    );
  }

  Widget _buildHeader() => Text(
        R.strings.settingsSubscribedToHeader,
        style: R.styles.appHighlightText,
      );

  Widget _buildTitle() => Text(
        R.strings.settingsXaynPremium,
        style: R.styles.appScreenHeadline,
      );

  Widget _buildInfo() {
    final dateString = endDate.shortDateFormat;
    final infoString = subscriptionType == SubscriptionType.paid
        ? R.strings.subscriptionRenewsMonthlyText
        : R.strings.promoCodeValidUntilText;
    final infoStringWithDate =
        infoString.replaceFirst('%s', '__${dateString}__');
    return SuperRichText(
      text: infoStringWithDate,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: R.styles.appBodyText,
      othersMarkers: [
        MarkerText(
          marker: '__',
          style: R.styles.appBodyText!.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final footerString = Platform.isIOS
        ? R.strings.subscriptionPlatformInfoApple
        : R.strings.subscriptionPlatformInfoGoogle;
    final richText = SuperRichText(
      text: footerString,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: R.styles.dialogBodySmall,
      othersMarkers: [
        MarkerText(
          marker: '__',
          style:
              R.styles.dialogBodySmall!.copyWith(color: R.colors.primaryAction),
        ),
      ],
    );
    return AppGhostButton(
      contentPadding: EdgeInsets.zero,
      child: richText,
      onPressed: onCancelSubscriptionPressed,
    );
  }

  Widget _buildDoneButton(BuildContext context) => AppGhostButton.text(
        R.strings.doneButtonTitle,
        onPressed: () => closeBottomSheet(context),
      );
}
