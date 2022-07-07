import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class ResettingAIBottomSheet extends BottomSheetBase {
  ResettingAIBottomSheet({Key? key, VoidCallback? onSystemPop})
      : super(
          key: key,
          body: _ResettingAI(
            onSystemPop: onSystemPop,
          ),
        );
}

class _ResettingAI extends StatefulWidget {
  const _ResettingAI({
    Key? key,
    this.onSystemPop,
  }) : super(
          key: key,
        );

  final VoidCallback? onSystemPop;

  @override
  State<_ResettingAI> createState() => __ResettingAIState();
}

class __ResettingAIState extends State<_ResettingAI> with BottomSheetBodyMixin {
  @override
  Widget build(BuildContext context) {
    ///TODO
    ///A timer used for closing the bottom sheet after few seconds
    ///To remove when the business logic will be implemented
    Future.delayed(const Duration(seconds: 3), () => closeBottomSheet(context));

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: R.dimen.unit3,
        ),
        CircularProgressIndicator(
          color: R.colors.icon,
        ),
        SizedBox(
          height: R.dimen.unit2,
        ),
        Text(R.strings.bottomSheetResettingAIBody),
        SizedBox(
          height: R.dimen.unit3,
        ),
      ],
    );

    return body;
  }
}
