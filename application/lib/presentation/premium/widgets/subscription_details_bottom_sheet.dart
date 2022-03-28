import 'dart:io';

import 'package:flutter/material.dart';
import 'package:super_rich_text/super_rich_text.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/infrastructure/util/string_extensions.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/utils/datetime_utils.dart';

const String _kTextPlaceholder = '__';

typedef OnSubscriptionCancelTapped = Function();

class SubscriptionDetailsBottomSheet extends BottomSheetBase {
  SubscriptionDetailsBottomSheet({
    Key? key,
    required SubscriptionStatus subscriptionStatus,
    required OnSubscriptionCancelTapped onSubscriptionCancelTapped,
  }) : super(
          key: key,
          body: _SubscriptionDetails(
            subscriptionStatus: subscriptionStatus,
            onSubscriptionCancelTapped: onSubscriptionCancelTapped,
          ),
        );
}

class _SubscriptionDetails extends StatelessWidget with BottomSheetBodyMixin {
  final SubscriptionStatus subscriptionStatus;
  final OnSubscriptionCancelTapped onSubscriptionCancelTapped;

  const _SubscriptionDetails({
    Key? key,
    required this.subscriptionStatus,
    required this.onSubscriptionCancelTapped,
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
    final infoString = R.strings.subscriptionRenewsMonthlyText;
    final infoStringWithDate =
        infoString.format('$_kTextPlaceholder$dateString$_kTextPlaceholder');
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
    return SuperRichText(
      text: footerString,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: R.styles.dialogBodySmall,
      othersMarkers: [
        MarkerText.withFunction(
          marker: _kTextPlaceholder,
          functions: [onSubscriptionCancelTapped],
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
