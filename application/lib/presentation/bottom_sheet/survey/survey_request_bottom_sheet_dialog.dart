import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/widget/animation_player.dart';

class SurveyRequestBottomSheet extends BottomSheetBase {
  SurveyRequestBottomSheet({
    Key? key,
    required VoidCallback onTakeSurveyPressed,
  }) : super(
          key: key,
          body: _SurveyRequestView(onTakeSurveyPressed: onTakeSurveyPressed),
        );
}

class _SurveyRequestView extends StatefulWidget {
  final VoidCallback onTakeSurveyPressed;

  const _SurveyRequestView({
    Key? key,
    required this.onTakeSurveyPressed,
  }) : super(key: key);

  @override
  State<_SurveyRequestView> createState() => _State();
}

class _State extends State<_SurveyRequestView>
    with BottomSheetBodyMixin, TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      SizedBox(height: R.dimen.unit),
      _buildAnimation(),
      SizedBox(height: R.dimen.unit2),
      BottomSheetHeader(headerText: R.strings.takeSurveySubtitle),
      SizedBox(height: R.dimen.unit2),
      _buildText(),
      SizedBox(height: R.dimen.unit2_5),
      _buildTakeSurveyBtn(),
      SizedBox(height: R.dimen.unit1_5),
      _buildCloseBtn(),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildAnimation() => AnimationPlayer.asset(
        R.assets.lottie.survey,
        width: R.dimen.bottomSheetAnimationSize,
        height: R.dimen.bottomSheetAnimationSize,
      );

  Widget _buildTakeSurveyBtn() => SizedBox(
        width: double.maxFinite,
        child: AppRaisedButton.text(
          text: R.strings.takeSurveyTitle,
          onPressed: () {
            widget.onTakeSurveyPressed();
            closeBottomSheet(context);
          },
        ),
      );

  Widget _buildCloseBtn() => SizedBox(
        width: double.maxFinite,
        child: AppGhostButton.text(
          R.strings.general.btnClose,
          backgroundColor: R.colors.bottomSheetCancelBackgroundColor,
          onPressed: () => closeBottomSheet(context),
        ),
      );

  Widget _buildText() => Text(
        R.strings.takeSurveySubtitle,
        textAlign: TextAlign.center,
      );
}
