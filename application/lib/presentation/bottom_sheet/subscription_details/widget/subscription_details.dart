import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/subscription_details/manager/subscription_details_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/subscription_details/manager/subscription_details_state.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class SubscriptionDetailsBottomSheet extends BottomSheetBase {
  SubscriptionDetailsBottomSheet({
    Key? key,
    VoidCallback? onDonePressed,
  }) : super(
          key: key,
          body: _SubscriptionDetails(onDonePressed: onDonePressed),
        );
}

class _SubscriptionDetails extends StatefulWidget {
  final VoidCallback? onDonePressed;

  const _SubscriptionDetails({
    Key? key,
    this.onDonePressed,
  }) : super(key: key);

  @override
  State<_SubscriptionDetails> createState() => _SubscriptionDetailsState();
}

class _SubscriptionDetailsState extends State<_SubscriptionDetails>
    with BottomSheetBodyMixin {
  late final SubscriptionDetailsManager _subscriptionDetailsManager = di.get();

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<SubscriptionDetailsManager, SubscriptionDetailsState>(
        bloc: _subscriptionDetailsManager,
        listener: (_, __) => _closeSheet(),
        builder: (context, state) {
          final header = Text(R.strings.settingsSubscribedToHeader);

          final title = Text(R.strings.settingsXaynPremium);

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
        },
      );

  void _closeSheet() {
    closeBottomSheet(context);
    widget.onDonePressed?.call();
  }
}
