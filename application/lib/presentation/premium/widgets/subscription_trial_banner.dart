import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/utils/datetime_utils.dart';

class SubscriptionTrialBanner extends StatelessWidget {
  final DateTime trialEndDate;
  final VoidCallback? onPressed;

  const SubscriptionTrialBanner({
    Key? key,
    required this.trialEndDate,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stack = Stack(
      children: [
        _buildDecoration(),
        _buildTile(),
      ],
    );

    return ClipRRect(
      child: Container(
        height: R.dimen.unit9,
        child: stack,
        decoration: BoxDecoration(
          color: R.colors.settingsCardBackground,
          borderRadius: R.styles.roundBorder,
        ),
      ),
      borderRadius: R.styles.roundBorder,
    );
  }

  Widget _buildDecoration() => Positioned(
        top: 0,
        right: 0,
        child: SvgPicture.asset(
          R.assets.icons.premiumDecoration,
        ),
      );

  Widget _buildTile() {
    final icon = Center(
      child: Padding(
        padding: EdgeInsets.only(right: R.dimen.unit2),
        child: SvgPicture.asset(
          R.assets.icons.diamond,
          color: R.colors.primaryAction,
          width: R.dimen.unit3,
          height: R.dimen.unit3,
        ),
      ),
    );

    final spacing = SizedBox(
      width: R.dimen.unit0_5,
      height: R.dimen.unit0_5,
    );

    final title = Text(
      trialEndDate.trialEndDateString,
      style: R.styles.mStyle,
    );

    final subtitle = Row(
      children: [
        Text(
          R.strings.trialBannerSubscribeNow,
          style: R.styles.sBoldStyle.copyWith(
            color: R.colors.primaryAction,
          ),
        ),
        spacing,
        SvgPicture.asset(
          R.assets.icons.arrowRight,
          color: R.colors.primaryAction,
          width: R.dimen.unit1_5,
          height: R.dimen.unit1_5,
        ),
      ],
    );

    final row = Row(
      children: [
        icon,
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title,
            spacing,
            subtitle,
          ],
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );

    final padding = Padding(
      padding: EdgeInsets.only(
        left: R.dimen.unit2,
        right: R.dimen.unit0_5,
      ),
      child: row,
    );
    final embedInButton = onPressed != null;
    return embedInButton
        ? AppGhostButton(
            child: padding,
            onPressed: onPressed,
          )
        : padding;
  }
}
