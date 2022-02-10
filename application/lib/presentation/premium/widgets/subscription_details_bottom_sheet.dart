import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

enum SubscriptionType {
  paid,
  promoCode,
}

class SubscriptionDetailsBottomSheet extends BottomSheetBase {
  SubscriptionDetailsBottomSheet({
    Key? key,
    required SubscriptionType subscriptionType,
    required DateTime endDate,
  }) : super(
          key: key,
          body: _SubscriptionDetails(
            subscriptionType: subscriptionType,
            endDate: endDate,
          ),
        );
}

class _SubscriptionDetails extends StatelessWidget {
  final SubscriptionType subscriptionType;
  final DateTime endDate;

  const _SubscriptionDetails({
    Key? key,
    required this.subscriptionType,
    required this.endDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final header = Text(R.strings.settingsSubscribedToHeader);

    final title = Text(
      R.strings.settingsXaynPremium,
      style: R.styles.appBodyText,
    );

    final info = Text(R.strings.subscriptionRenewsMonthlyText);

    final footer = Text(R.strings.subscriptionPlatformInfoApple);

    final doneButton = Text(R.strings.doneButtonTitle);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        title,
        info,
        footer,
        doneButton,
      ],
    );
  }

  // void _closeSheet() {
  //   closeBottomSheet(context);
  //   widget.onDonePressed?.call();
  // }
}
