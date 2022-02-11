import 'package:flutter/material.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/premium/widgets/subscription_trial_banner.dart';
import 'package:xayn_discovery_app/presentation/utils/datetime_utils.dart';

mixin SubscriptionTrialBannerStateMixin<T extends StatefulWidget> on State<T> {
  void showTrialBanner([VoidCallback? onTap]) => InAppNotification.show(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: R.dimen.unit),
          child: SubscriptionTrialBanner(
            trialEndDate: subscriptionEndDate,
          ),
        ),
        context: context,
        onTap: onTap,
        duration: const Duration(seconds: 3),
      );
}
