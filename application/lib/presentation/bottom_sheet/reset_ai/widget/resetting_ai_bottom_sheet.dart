import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/reset_ai/manager/resetting_ai_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/reset_ai/manager/resetting_ai_state.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class ResettingAIBottomSheet extends BottomSheetBase {
  ResettingAIBottomSheet({
    Key? key,
    VoidCallback? onSystemPop,
    required VoidCallback onResetAIFailed,
  }) : super(
          key: key,
          body: _ResettingAI(
            onSystemPop: onSystemPop,
            onResetAIFailed: onResetAIFailed,
          ),
        );
}

class _ResettingAI extends StatefulWidget {
  const _ResettingAI({
    Key? key,
    this.onSystemPop,
    required this.onResetAIFailed,
  }) : super(
          key: key,
        );

  final VoidCallback? onSystemPop;
  final VoidCallback onResetAIFailed;

  @override
  State<_ResettingAI> createState() => __ResettingAIState();
}

class __ResettingAIState extends State<_ResettingAI> with BottomSheetBodyMixin {
  late final ResettingAIManager _resettingAIManager = di.get();

  @override
  void didChangeDependencies() {
    _resettingAIManager.resetAI();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
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

    return BlocBuilder<ResettingAIManager, ResettingAIState>(
      bloc: _resettingAIManager,
      builder: (_, state) => state.map(
        loading: (_) => body,
        resetSucceeded: (_) {
          closeBottomSheet(context);
          return body;
        },
        resetFailed: (_) {
          widget.onResetAIFailed();
          closeBottomSheet(context);
          return body;
        },
      ),
    );
  }
}
