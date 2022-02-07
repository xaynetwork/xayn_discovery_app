import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class SubscriptionTrialBanner extends StatelessWidget {
  final DateTime trialEndDate;
  final VoidCallback onPressed;

  const SubscriptionTrialBanner({
    Key? key,
    required this.trialEndDate,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Container(
        height: 72,
        child: _buildTile(),
        decoration: BoxDecoration(
          color: R.linden.colors.settingsCardBackground,
          borderRadius: R.linden.styles.roundBorder,
        ),
      ),
      borderRadius: R.linden.styles.roundBorder,
    );
  }

  Widget _buildTile() {
    final icon = Center(
      child: Padding(
        padding: EdgeInsets.only(right: R.linden.dimen.unit2),
        child: SvgPicture.asset(
          R.linden.assets.icons.diamond,
          color: R.linden.colors.primaryAction,
          width: R.linden.dimen.unit3,
          height: R.linden.dimen.unit3,
        ),
      ),
    );
    final spacing = SizedBox(
      width: R.dimen.unit0_5,
      height: R.dimen.unit0_5,
    );
    final title = Text(
      'Your trial ends in 1 day',
      style: R.styles.newSettingsSectionTitle,
    );
    final subtitle = Row(
      children: [
        Text(
          R.strings.trialBannerSubscribeNow,
          style: R.styles.appThumbnailText?.copyWith(
            color: R.linden.colors.primaryAction,
          ),
        ),
        spacing,
        SvgPicture.asset(
          R.linden.assets.icons.arrowRight,
          color: R.linden.colors.primaryAction,
          width: R.linden.dimen.unit1_5,
          height: R.linden.dimen.unit1_5,
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

    return AppGhostButton(
      child: Padding(
        padding: EdgeInsets.only(
          left: R.linden.dimen.unit2,
          right: R.linden.dimen.unit0_5,
        ),
        child: row,
      ),
      onPressed: onPressed,
    );
  }
}
