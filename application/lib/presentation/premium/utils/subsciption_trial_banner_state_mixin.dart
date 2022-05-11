import 'package:flutter/material.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/premium/widgets/subscription_trial_banner.dart';

const _kTrialBannerDisplayDuration = Duration(seconds: 3);

mixin SubscriptionTrialBannerStateMixin<T extends StatefulWidget> on State<T> {
  void showTrialBanner({
    required DateTime trialEndDate,
    required VoidCallback onTap,
  }) =>
      InAppNotification.show(
        child: Padding(
          padding: EdgeInsets.only(
              top: R.dimen.unit2,
              left: R.dimen.unit2_5,
              right: R.dimen.unit2_5),
          child: SizedBox(
            height: 72,
            child: SubscriptionTrialBanner(
              trialEndDate: trialEndDate,
            ),
          ),
        ),
        context: context,
        onTap: onTap,
        duration: _kTrialBannerDisplayDuration,
      );
}
